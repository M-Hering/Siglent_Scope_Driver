function meaned = array_mean_to(data, n)
  % Takes the averrage of so many points that n points remain
  if n>0
    meaned = array_mean(data, floor(length(data)/n));
  else
    meaned = data;
  end
end
