function real_params = current_data_set(feedback)

  real_params.text = "This was part of a measurement series to get the turing bifurcation. Thus there should be number of files with different feedbacks. The resistances, coapacitances and the delay given in this description are in Ohm, Farad and Second. rp_out is the signal comming out of the red pitaya, picked up by a scope. rp_in is the signal after the MFB and thus the signal that is put into the red pitaya.";
  real_params.feedback = feedback;
  %real_params.ufeedback = 0.006;
  real_params.delay = 10e-3;
  %real_params.udelay = 162e-9;
  real_params.R1  = 510;
  %real_params.uR1 = 0.02;
  real_params.C2  = 77e-9;
  %real_params.uC2 = 0.03;
  real_params.R3  = 6000;
  %real_params.uR3 = 0.03;
  real_params.R4  = 510;
  %real_params.uR4 = 0.02;
  real_params.C5  = 1e-9;%0.333e-9;
  %real_params.uC5 = 0.03;
  real_params.k = 2; % Th factor needed to be aplied on the voltage to get the x of the time trace in unit 1/V.

  real_params.abs_uvolt       = 0.01; % The uncertainty of each individual voltage data point
  real_params.abs_uvolt_shift = 0.02; % The uncertainty the global shirt (which is expected to be zero but might not, so it has an uncertainty)
end

