function volt = data2volt(data)
  % Transforms a data struct recieved from get_data into a double array of volt
  % values.
  volt = double(data.binary) * data.params.v_scale + data.params.v_offset;
end
