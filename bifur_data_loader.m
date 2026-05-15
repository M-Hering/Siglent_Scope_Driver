function bifur_data_loader(path, feedback)
  pkg load instrument-control;
  addpath(genpath('./..'))

  path = [path, "/"];
  filename = [path, "fb_", num2str(feedback), ".mat"];

  t0 = vxi11("10.42.0.207");
  scope.write = @(command) vxi11_write(t0, command);
  scope.read  = @(data_length) vxi11_read(t0, data_length);
  scope.close = @() vxi11_close(t0);

  scope.write("STOP");
  pause( 1 );

  scope.write( ":WAVeform:SOURce C2" );                           # Set source
  data.rp_in.params = request_params(scope);                      # Get params
  data.rp_in.binary = request_binary(scope, data.rp_in.params);   # Get data

  scope.write("TRMD AUTO");
  scope.close() # Close connection

  data.description = current_data_set( feedback );

  sqr = @(x)x.*x;
  display(["<V^2> = ", num2str(sqrt(mean(sqr(data2volt(data.rp_in))))) ]);

  if( !exist(path, 'dir') )
    mkdir(path)
  endif
  save("-mat-binary", filename, "data") # Save data

  display("done");
endfunction
