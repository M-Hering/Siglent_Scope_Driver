function real_params = current_data_set(feedback)

  real_params.text = "";
  real_params.feedback = feedback;
  %real_params.ufeedback = 0.006;
  real_params.delay = 10e-3;
  %real_params.udelay = 162e-9;
  real_params.R1  = 508;
  %real_params.uR1 = 0.02;
  real_params.C2  = 77.85e-9;
  %real_params.uC2 = 0.03;
  real_params.R3  = 6700;
  %real_params.uR3 = 0.03;
  real_params.R4  = 508;
  %real_params.uR4 = 0.02;
  real_params.C5  = 0.99e-9;%0.333e-9;
  %real_params.uC5 = 0.03;
  real_params.k = 1/0.526666; % The factor needed to be aplied on the voltage to get the x of the time trace in unit 1/V.
                              % This value is effectively the inverse of the cut off voltage set in the red pitaya. Due to bad mapping this value needs to be measured.
  real_params.abs_uvolt       = 0.01; % The uncertainty of each individual voltage data point
  real_params.abs_uvolt_shift = 0.02; % The uncertainty the global shirt (which is expected to be zero but might not, so it has an uncertainty)
end

