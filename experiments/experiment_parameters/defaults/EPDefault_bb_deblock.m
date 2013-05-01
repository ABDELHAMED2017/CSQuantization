% Default parameter settings for using block-based acquisition w/ deblocking filter.
csq_deps('common');

% General Settings
params.block_based = 1;                            	% Block based
params.block_dim = [32 32];                     	% Block acq. dimensions

% Smoothing parameters
params.smoothing.id = 'deblock';					% Wiener smoothing
params.smoothing.radius = 2;						% Deblocking radius

