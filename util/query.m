function resp = query(scope, command)
  # Uses the read and write function in scope to send the command to the sope
  # and recieve the response. The response is cut to its length, transformed
  # to a string and returned.
  scope.write(command);
  [data, len] = scope.read(10000);
  if( data(len) ~= 0x0A )
    display(["Query ", command, "failed. No 0x0A byte at the end of the response."])
    return
  endif

  resp = char( data(1:len-1) );
endfunction
