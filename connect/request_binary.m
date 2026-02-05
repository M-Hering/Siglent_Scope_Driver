function data_total = request_binary(scope, params)
  DATA_HEADER_SIZE_INIT1 = 1; % The Data starts with a single '#' = 35
  DATA_HEADER_SIZE_INIT2 = 1; % Then there is a single decimal number, which gives the length of the following segment
% DATA_HEADER_SIZE_DATA_SIZE;   This segment is a decimal number giving the number of data points (each data point is one byte, so one entry in the array)
% DATA_HEADER_SIZE;             The combined size of the header
% DATA_SIZE;                    The size of the data
  DATA_TAIL_SIZE = 2;         % The data ends with two 0x0A = 10

  % Check how in many bytes each data point is send.
  if(     strcmp( params.waveform_width, "BYTE" ) )
    DATA_BYTES_PER_POINT = 1;
  elseif( strcmp( params.waveform_width, "WORD" ) )
    DATA_BYTES_PER_POINT = 2;
  else
    display("Error! Waveform_width is not BYTE or WORD. So the format is not supported.")
    DATA_BYTES_PER_POINT = 1; % We put 1 and hope for the best.
  end

  data_total = [];

  points_per_transfer = params.max_point;

  scope.write([":WAVeform:POINt ", num2str(points_per_transfer)] );
  current_start = 0;
  while current_start < params.data_point_count
    expected_point_count = min( params.data_point_count - current_start, points_per_transfer );
    expected_data_size = expected_point_count * DATA_BYTES_PER_POINT;

    tic
    scope.write([":WAVeform:STARt ", num2str(current_start)] );
    scope.write(':WAVEFORM:DATA?');
    [data_raw, len] = scope.read(expected_data_size+1000);
    time = toc;
    display(["Recieved ", num2str(len), " bytes of data in ", num2str(time), " s."]);

    if( char(data_raw(1)) ~= '#' )
      display(['Error! Wrong answer format!: ', char(data_raw(1:7))]);
      return
    end
    %This number gives the length of the following number, which then gives the number of data points.
    DATA_HEADER_SIZE_DATA_SIZE = str2num(char(data_raw(2)));
    DATA_HEADER_SIZE = DATA_HEADER_SIZE_INIT1 + DATA_HEADER_SIZE_INIT2 + DATA_HEADER_SIZE_DATA_SIZE;
    DATA_SIZE = str2num( char(data_raw(
                                DATA_HEADER_SIZE_INIT1+DATA_HEADER_SIZE_INIT2+1:
                                DATA_HEADER_SIZE
                              )) );

    % The data head is supposed to end with two 0x0A.
    % The +1 in the index comes from arrays beeing started with the index 1.
    if( data_raw(DATA_HEADER_SIZE+DATA_SIZE+1) ~= 0x0A || data_raw(DATA_HEADER_SIZE+DATA_SIZE+2) ~= 0x0A )
      display('Error! Check of ending of data failed!');
      return
    end
    if( length(data_raw) < DATA_HEADER_SIZE + DATA_SIZE + DATA_TAIL_SIZE )
      display('Error! Recieved data is shorter than expected. Probably corupted data!');
    end

    if    ( DATA_SIZE < expected_data_size )
      display(["Error! Recieved data is shorter than expected. Probably corupted data! \tExpected: ", num2str(expected_data_size), " but got ", num2str(DATA_SIZE), " bytes!"]);
    elseif( DATA_SIZE > expected_data_size )
      display(["Error! Recieved data is longer than expected. Probably corupted data! \tExpected: ", num2str(expected_data_size), " but got ", num2str(DATA_SIZE), " bytes!"]);
    end

    data_total = [data_total, data_raw(DATA_HEADER_SIZE+1 : DATA_HEADER_SIZE+DATA_SIZE)];

    current_start += expected_point_count;
  end

  if    ( length(data_total) < params.data_point_count * DATA_BYTES_PER_POINT )
    display(["Error! Data transmission yielded less data than expected. Data might be corupted! \tExpected: ", num2str(params.data_point_count), " but got ", num2str(length(data_total)), " bytes!"]);
  elseif( length(data_total) > params.data_point_count * DATA_BYTES_PER_POINT )
    display(["Error! Data transmission yielded more data than expected. Data might be corupted! \tExpected: ", num2str(params.data_point_count), " but got ", num2str(length(data_total)), " bytes!"]);
  end

  % In case we got the data not in bytes but in words (so every two bytes form
  % together an int16 number) we need to reshape the data. As this does not
  % change the binary size of the data, we already do it here.
  if(     DATA_BYTES_PER_POINT == 1 )
    data_total = typecast(        data_total,         'int8' );
  elseif( DATA_BYTES_PER_POINT == 2 )
    data_total = typecast(reshape(data_total, 2, []), 'int16');
  else
    % Asl said in the eginning, we have no idea how to interpret the data.
    data_total = typecast(        data_total,         'int8' );
  end
end
