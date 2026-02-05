function plot_data_cut(data, cut_to)
  % Get the parameters and the byte data to plot. Optional is the cut_to,
  % which will cut of as many points from the beginning and only plot these.
  % The default is 10000. If set to 0 or bigger than the number of data
  % points all points are plotted

  % Check parameter
  if( ~exist('cut_to') )
    cut_to = 10000;
  elseif( cut_to <= 0 || cut_to > length(data.binary) )
    cut_to = length(data.binary);
  end

  % Get the data to plot
  volt_data = data2volt( data );
  time_data = data2time( data );

  % PLot the stuff
  plot(time_data(1:cut_to), volt_data(1:cut_to), '-')
end
