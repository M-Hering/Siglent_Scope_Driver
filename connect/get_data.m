function data = get_data(connection_type, scope_adress, scope_source, plot, file_name)
  % Uses request params and request data to retrieve parameters from the scope and the current binary data. The data is not transformed into actual voltage and time values as those would need significantly more disk space. Instead the data is returned in a binary format and additionally the params needed to get the voltage or time values. The data can be transformed with data2volt and data2time and plotted with plot_data. 'scope_adress' is the ip-adress of the scope. Other types of communication are not supported yet. 'scope_source' is the source the data should be pulled from. So for example "C1" if the data from the first probe should be pulled. If 'plot' is given and true the data is plotted right away. If file_name is given and not an empty string the params and data are also stored in a file.
  % Example call: get_data('vxi', '10.42.0.100', 'C4', true, 'outputfile');
  % Open VXI11 connection to scope with ip 10.42.0.100 and set calls to scope.
  if    ( strcmp( toupper(connection_type), "VXI" ) )
    t0 = vxi11(scope_adress);
    scope.write = @(command) vxi11_write(t0, command);
    scope.read  = @(data_length) vxi11_read(t0, data_length);
    scope.close = @() vxi11_close(t0);
  elseif( strcmp( toupper(connection_type), "USB" ) )
    t0 = usbtmc(scope_adress);
    scope.write = @(command) usbtmc_write(t0, command);
    scope.read  = @(data_length) usbtmc_read(t0, data_length);
    scope.close = @() usbtmc_close(t0);
  else
    display("Error! Unsupported connection type. Currently only VXI and USB are supported.")
    return
  end

  scope.write( [":WAVeform:SOURce ", scope_source] ); % Set source
  data.params = request_params(scope);                % Get params
  data.binary = request_binary(scope, data.params);   % Get data
  scope.close()                                       % Close connection

  if( exist('plot') && plot)
    plot_data_avg(data, 10000)
  end

  if( exist('file_name') && length(file_name)>0 )
    save("-mat-binary", [file_name, '.mat'], "data")            % Save data
  end
end
