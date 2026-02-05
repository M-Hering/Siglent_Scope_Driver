function params = request_params(scope)
  % In case we were using SCPI commands, this command would set the scope to not
  % repeat the commands in the beginning of its responses. As we are not using
  % any SCPI commands it is nt important for us. I'll still leave it here, in
  % case someone else compares my code to someone elses code and is stumbling
  % over this command like I did:       scope.write("CHDR OFF");

  % We ask whether we are in 8 or 10 bit mode and depending on that we set the
  % data width. Byte means the data is send in one Byte big chunks. Where as
  % Word means that every two bytes in the recieved data is need to be
  % understood as a single int16 data point.
  adc_bit = query( scope, ":ACQuire:RESolution?" );
  if    ( strcmp( adc_bit, "8Bits"  ) )
    scope.write(":WAVeform:WIDTh BYTE");
  elseif( strcmp( adc_bit, "10Bits" ) )
    scope.write(":WAVeform:WIDTh WORD");
  else
    display("Error! The acquire resolution is ", adc_bit, ". This is not supported. Data transmission is set to Word in hope, the scope supports to send its data this way. Data recieved might be completely corrupted or y-scale could be wrong.")
    scope.write(":WAVeform:WIDTh WORD");
  end

  % The source the data is beeing recieved from (most likely one of the probes)
  params.source = query(scope, ":WAVeform:SOURce?");
  % The maximum number of points that can be asked for.
  params.max_point = str2num( query( scope, ":WAVeform:MAXPoint?") );

  % This request asks for a whole bunch of parameters that are in binary form. We first check the binary shape of the respone and then read and interpret all the binary data.
  reply = query(scope, ":WAVeform:PREamble?");

  if     ( length(reply) ~= 357 )
    display("Error! Preamble reply has wrong length. Data is in an unknown format_");
    return;
  elseif ( ~isequal(reply(1:11), "#9000000346") ) % The % is generally the beginning of the data. The 9 gives length of the next data block which is 000000346. This gives the length of the actually transmitted data, which itself comes next. It would be better to analyse these numbers correctly (as was done in get_data, as the datasize there can varry. But here there seem to be constant and I was lazy.
    display("Error! Preamble reply starts with an unknown header. Data is in an unknown format_");
    return;
  end

  data = reply(12:357);
  if     ( ~isequal(data(1:8), "WAVEDESC") )
    display( ["Error! Got an unknown Descriptor name. Excpected \'WAVEDESC\' but got \'", char(data(1:16)), "\'." ]);
    return;
  elseif ( ~isequal(data(17:23), "WAVEACE") )
    display( ["Error! Got an unknown Template name. Excpected \'WAVEACE\' but got \'", char(data(17:32)), "\'." ]);
    return;
  elseif ( typecast(data(35:36), 'int16') ~= 0 )
    display( 'Error! COMM_ORDER recieved is not 0. Meaning the data is not wirtten in least-significant-bit_ But thus this function can only read data written in least-significant-bit_' );
    return;
  end

  params.data_point_count = typecast( data(117:120), 'int32' ); % The amount of data points available.
  params.data_size        = typecast( data( 61: 64), 'int32' ); % The amount of bytes these data points are occupying.

  comm_type = typecast(data(33:34), 'int16');
  if( comm_type == 0 )
    params.waveform_width = "BYTE"; % The data is beeing stored in individual bytes.
    if( params.data_point_count ~= params.data_size )
      display(["Error! Data is supposed to be stored in bytes, but recieved data_point_count (", num2str(params.data_point_count), ") is not equal to data size (", num2str(params.data_size), ")."]);
    end
  elseif( comm_type == 1 )
    params.waveform_width = "WORD"; % The data is stored in two bytes (words) each.
    if( 2*params.data_point_count ~= params.data_size )
      display(["Error! Data is supposed to be stored in words, but recieved data_point_count (", num2str(params.data_point_count), ") is not double the data size (", num2str(params.data_size), ")."]);
    end
  else
    display(["Error! COMM_TYPE has unknown value: ", num2str(comm_type), ". Only 0 (Byte) and 1 (Word) a known values."])
    return
  end


  params.v_gain_no_probe        = typecast (uint8 (data(157:160)), "single"); % The vertical scale of the data (voltage) without considering the probe factor
  params.v_offset_no_probe      = typecast (uint8 (data(161:164)), "single"); % The vertical offset of the data (voltage)
  params.v_code_per_div         = typecast (uint8 (data(165:168)), "single"); % The data is in bytes (0 to 255) and there are 8 divs. So naively a byte value of 256/8=32 should mean a voltage of v_div_ However, the data actually covers a bit more than the display. Thus we dont have to devide the byte data by 32, but by the value gotten in this query.
  params.probe_attenuation      = typecast (uint8 (data(329:332)), "single"); % The factor given by the probe used. Typically this is 10 as we use 10x probes.
  params.v_div    = params.v_gain_no_probe * params.probe_attenuation;    % The vDiv selected on the scope
  params.v_scale  = params.v_div / params.v_code_per_div;                 % The factor the byte data has to be multiplied with to get the voltage. (Multiply before adding the v_offset)
  params.v_offset = -params.v_offset_no_probe * params.probe_attenuation; % This offset must be added to the voltage to account for the zero value.
  % The voltage value can now be calculated with the formular: signed_byte*v_div+v_offset

  params.v_coupling = {'DC', 'AC', 'GND'}{ 1 + typecast( data(327:328), 'int16' ) }; % The coupling used for the probe.
  params.adc_bit                = typecast( data(173:174), 'int16' ); % The encoding of the data. It can be set to 8 bit or 10 bit_ (10 bit might not be implemented yet)

  params.t_interval                = typecast (uint8 (data(177:180)), "single"); % Two data points have this value in seconds as time difference.
  params.t_scale = params.t_interval;
  params.sampling_rate = 1 / params.t_scale;
  params.t_user_offset          = typecast (uint8 (data(181:188)), "double"); % The horizontal (time) offset in seconds.
  params.t_div_index            = typecast( data(325:326), 'int16' ); % The time div is needed to get the zero value (the moment the trigger hit). This is a short givving the index in the following array.
  t_div_enum = [200e-12,500e-12, 1e-9, 2e-9, 5e-9, 10e-9, 20e-9, 50e-9, 100e-9, 200e-9, 500e-9, 1e-6, 2e-6, 5e-6, 10e-6, 20e-6, 50e-6, 100e-6, 200e-6, 500e-6, 1e-3, 2e-3, 5e-3, 10e-3, 20e-3, 50e-3, 100e-3, 200e-3, 500e-3, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000];
  params.t_div = t_div_enum(params.t_div_index+1);                     % The time div set on the scope.
  params.t_div_count = 10; % This is hard coded, as I don't have a way to ask for this yet_
  params.t_offset = params.t_user_offset - params.t_div*params.t_div_count/2;
  % The time value can now be calculated with the formular: index*t_div+t_offset

end
