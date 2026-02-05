function meaned = array_mean_to(data, n)
  % Takes the averrage of so many points that n points remain
  meaned = array_mean(data, floor(length(data)/n));
end
