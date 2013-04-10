% calling_experiment.m
% 
% Demonstrates how to call the experiment modules.
clear

csq_deps('common','experiments','wavelet','ssim','bcs-spl-dpcm','bcsspl');

% Experiment settings
filename = 'lena';
method = 'bcsspl';
xform = 'dwt2d';
quant = 'dpcm';
projection = 'binary';

image = [filename '.jpg'];
bitrates = 0.1:0.1:1.5;

repo_dir = csq_get_repo_dir();
results_filename = [filename '_' method '_' xform '_' quant '_' projection '.mat'];
results_path = [repo_dir '/experiments/results/' results_filename];

% Set general parameters
params.block_based = 1;
params.block_dim = [8 8];
params.rand_seed = 1;
params.verbose = 1;

% Projection
params.projection.id = projection;
params.projection.subrate = [0.05 0.08 0.11 0.11 0.14 0.17 0.2 0.25 0.33 0.37 0.4 0.44 0.47 0.51 0.54];

% Transform
params.transform.id = xform;

% Q-BCS-SPL parameters
params.qbcsspl.maxIter = 400;
params.qbcsspl.tol = 0.0001;
params.qbcsspl.quant = quant;
params.qbcsspl.meanSubtraction = 1;
params.qbcsspl.bits = [4 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6]; 


% Call the module
image_ratedistortion_experiment(image,bitrates,results_path,@experiment_module_bcsspl,params);
