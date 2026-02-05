function plot_data_avg(data, average_to)
  % Get the parameters and the byte data to plot. Optional is the average_to,
  % which will take the average of so many points that only average_to many are
  % left. The default is 1000. If set to 0 or bigger than the number of data
  % points no average is taken

  % Check parameter
  if( ~exist('average_to') )
    average_to = 1000;
  elseif( average_to <= 0 || average_to > length(data.binary) )
    average_to = length(data.binary);
  end

  % Get the data to plot
  volt_data = data2volt( data );
  time_data = data2time( data );

  % PLot the stuff
  plot(array_mean_to(time_data, average_to), array_mean_to(volt_data, average_to), '-')
end
