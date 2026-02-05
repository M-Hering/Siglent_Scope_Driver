function meaned = array_mean(data, n)
  % Takes the averrage of each n elements
  if(n == 1)
    meaned = data;
  elseif(n > 1)
    len = length(data);
    cut_length = len - mod(len, n);
    meaned = mean(reshape(data(1: cut_length), [n, cut_length/n]));
  end
end
