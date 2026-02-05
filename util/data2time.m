function time = data2time(data)
  % Transforms a data struct recieved from get_data into a double array of time
  % values in seconds.
  time = (0: length(data.binary)-1)*data.params.t_scale + data.params.t_offset;
end
