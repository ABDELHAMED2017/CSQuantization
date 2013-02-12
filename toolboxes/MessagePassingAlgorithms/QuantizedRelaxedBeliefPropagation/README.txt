---------------------------------------------------------------------------
----------------------------- Content -------------------------------------
---------------------------------------------------------------------------

1) Contents of this folder
2) Problem Setting
3) Comments on Relaxed Belief Propagation
4) Comments on State Evolution
5) Comments on quantizer optimization
6) Additioanl Info

---------------------------------------------------------------------------
--------------------- Contents of this folder -----------------------------
---------------------------------------------------------------------------

This folder contains all the necessary source code for running Relaxed
Belief Propagation (RBP) and State Evolution (SE) algorithms. It 
additionally contains code for finding optimal mean-squared error 
quantizers for reconstruction with RBP.

RBP is an iterative algorithm for estimating signals from random linear
measurements. It has been originally developed for CDMA multiuser detection
but has later been succesfully applied to compressive sensing (CS)
estimation. SE is a simpler algorithm capable of predicting MSE performance
of RBP under the large matrix setting. For more information about RBP in
general and SE refer to "Estimation with Random Linear Mixing, Belief 
Propagation and Compressive Sensing" by Sundeep Rangan.


This folder contains 7 MATLAB functions:
a) RunQuantizerOptimization.m (*)
b) RunSampleRbp.m (*)
c) RunSampleStateEvolution.m (*)
d) stateEvolution.m
e) reconstructRbp.m
f) createQuantizer.m
g) quantizeMeasurements.m

The main files are stateEvolution.m and reconstructRbp.m which run SE and
RBP respectively. Files with (*) are provided to demonstrate how to call
these functions to decode, predict, or optimize and can be run directly.
The final two files createQuantizer.m and quantizerMeasurements.m are
provided for convenience, to create quantizer object required by SE and RBP
functions and to quantizer measurements. More help can be found directly in
the code comments.

These files have been programmed and tested on MATLAB Version 7.11.0.584
(R2010b). Mathworks do not has a clear policy on backward compatibility,
hence some parts of MATLAB might evolve requiring small modifications in
this code. 

We have been able to successfully run this code on MATLAB R2008a
with minor modifications, which include replacing function return values ~ 
(feature intruduced after 2010) by some variable name, and removing the 
command 'matlabpool('size')' from RunQuantizerOptimization.m.

---------------------------------------------------------------------------
------------------------- Problem Setting ---------------------------------
---------------------------------------------------------------------------

The problem setting considered in this code reflects the paper submitted to
the ISIT 2011 conference:
"Optimal Quantization for Compressive Sensing under Message Passing 
Reconstruction" by U.Kamilov, V.Goyal, S. Rangan.
Preprint: http://www.arxiv.com/abs/1102.4652

Sparse signal of length n is acquired by measurement matrix Phi of
dimensions [m x n] where m < n. We denote by beta = n/m the undersampling
rate of the matrix. We assume that the input signal is distributed
according to i.i.d. Gauss-Bernoulli distribution, i.e. each element x_j of
vector x is distributed as

x_j ~ Normal(mean = 0, variance = 1/rho) with probability rho, or x_j = 0
with probability 1-rho,

which basically means that for rho=0.1, 90% of the 
vector x equals 0, while remaining 10% are distributed according to normal 
distribution of mean 0 and variance 10.

The measurements z = Phi * x are then further corrupted by additive white
Gaussian noise eta of mean 0 and variance v=sigma^2.

Finally we obtain measurements y by quantizing s = Phi*x + eta: y = Q(s).

The original paper presents equations for RBP and SE for more general model
with general signal prior distribution.

---------------------------------------------------------------------------
------------------------- Comments on RBP ---------------------------------
---------------------------------------------------------------------------

You can perform RBP estimation via calling the function:

[xhat, mse] = reconstructRbp(Phi, y, v, rho, q, x);
[xhat, mse] = reconstructRbp(Phi, y, v, rho, q, x, T);
[xhat, mse] = reconstructRbp(Phi, y, v, rho, q, x, T, tol);
[xhat, mse] = reconstructRbp(Phi, y, v, rho, q, x, T, tol, verbose);

where the output xhat is [1 x n] array representing the estimated signal and
mse is [T x 1]. The signal to be estimated x is not used in estimation, it
is merely used for computing MSE.

File RunSampleRbp demonstrates how parameters can be set and plots the
results of estimation.

********************************
IMPORTANT NOTE ON RECONSTRUCTRBP:
This implementation of RBP might have poor performance under certain
circumstances due to numerical issues.

Numerical problems arise when initial signal-to-noise ratio (SNR) is very
high and signal length n is not sufficiently large.

SNR is high when AWGN has very low variance (v < 0.001) and very high rate
quantizer is used.

To avoid this problem when using high rate quantizers set AWGN to some non
zero variance, e.g. v = 0.1 or 0.01. Alternatively you could increase the
length n of the signal.

The root cause of the issue lies in numerical integrations of Gaussian
random variables. RBP works by making gaussian assuptions and uses them
for estimation. When these gaussians have very small variance and 
integration takes place over the interval far away from the mean algorithm
might say that the integral is 0. In reality this integral is some small
value, but not zero, hence we this value is utilized later it deterioates
the estimate (error cumulation). Eventually algorithm might reconverge, but
it might oscilate.

To resolve root cause it is wise to do some computations in log domain. In
a way similar how it is done in machne learning community for gaussian
mixture models. Our current implementation utilizes normpdf(x, mean, var) 
function of MATLAB which in not optimal as it retults in 0 in some cases 
(abs(x-mean) > many times sqrt(var)).

You can find more info by reading the help of reconstructRbp and inspecting
its code.
Note that our AMP implementation does not run into this problem.
********************************

---------------------------------------------------------------------------
------------------------- Comments on SE ----------------------------------
---------------------------------------------------------------------------

SE prediction can be obtained by running:

mse = stateEvolution(mzinit, rho, beta, v, quantizer)
mse = stateEvolution(mzinit, rho, beta, v, quantizer, T)
mse = stateEvolution(mzinit, rho, beta, v, quantizer, T, tol)
mse = stateEvolution(mzinit, rho, beta, v, quantizer, T, tol, c)
mse = stateEvolution(mzinit, rho, beta, v, quantizer, T, tol, c, nSamples)
mse = stateEvolution(mzinit, rho, beta, v, quantizer, T, tol, c, nSamples, verbose)

where mse is [T x 1] matrix with per iteration MSE prediction. For more
information type

help stateEvolution

in MATLAB command line. To see how parameters can be set run 
RunSampleStateEvolution. It sets all required parameters and is commented
throughout. It also plots final prediction results.

---------------------------------------------------------------------------
--------------- Comments on quantizer optimization ------------------------
---------------------------------------------------------------------------

Function

results = RunQuantizerOptimization

demonstrates how SE framework can be utilized to optimize quantizers for
compressive sensing setting. It considers 6 types of quantizers including
4 obtained via SE, while other 2 are Uniform and Lloyds quantizers.

The file is mostly self contained, except calls to stateEvolution and
createQuantizer.

Optimization performed by finding best quantizer based on some optimization
criteria (described in more detail in the paper) for each measurement rate
(in bits/measurement). This implementation is an example and more elaborate
optimization schemes can be designed by using SE framework.

After finding the best quantizers the function displays a plot with MSE
performance for 3 quantizers: Lloyds, Optimal Regular and Optimal Binned.
Other performances can be plotted by similar means by accessing the 
contents of results structure.

For more help write

help RunQuantizerOptimization

in MATLAB command line.

To find Lloyds and Uniform quantizers we utilize code by Peter Kabal,
downloaded from Mathworks File Exchange webseite:

http://www.mathworks.com/matlabcentral/fileexchange/24333.

The copyright notice of the code allows its residtribution and modification
if the following copyright is included:

**********************************
% Copyright (c) 2009, Peter Kabal
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the McGill University nor the names 
%       of its contributors may be used to endorse or promote products derived 
%       from this software without specific prior written permission.
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
**********************************

---------------------------------------------------------------------------
------------------------- Additional Info ---------------------------------
---------------------------------------------------------------------------

Together with this code we will upload 'RxOptimization' MATLAB code, that
can be used to reproduce the results for the paper:

"Optimal Quantization for Compressive Sensing under Message Passing 
Reconstruction" by U.Kamilov, V.Goyal, S. Rangan.
Preprint: http://www.arxiv.com/abs/1102.4652

which was submitted for ISIT 2011.

It can be run by calling

RxOptimization;

script in MATLAB command line. The parameters can be modified directly in
the script. The script saves the results as MAT file that can be plotted
by running quantPlot.m script in 'Data and Plotting' sub-folder. The sub-
folder contains MAT files that have already been generated.

This code, contrary to RxOptimization, is cleaner and more refined version 
with additional comments that could be practical for people seeking to 
extend the work. Additionally to SE it provides implementation of RBP with
examples on how to run it (RunSampleRbp and reconstructRbp).