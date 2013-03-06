function [psi invpsi] = csq_generate_xform(xform,params)
% [psi inpsi] = csq_generate_xform(xform,param)
% Given a transform name and a set of accompanying parameters, this
% function will return two function handles which represent the forward and
% inverse transform.



switch xform
    case 'dct2d'
       [psi invpsi] = xform_dct2d_blk(params);
    case 'dct2d-blk'
       [psi invpsi] = xform_dct2d(params);   
    case 'dwt2d' 
       [psi invpsi] = xform_dwt2d(params);
    case 'ddwt2d'
       [psi invpsi] = xform_ddwt2d(params);
    otherwise
        return_str = sprintf('Transform "%s" is unsupported.',xform);
        error('csq_generate_xform:UnsupportedTransform',return_str);
end




%--------------------------------------------------

function [psi invpsi] = xform_dct2d_blk(params)
% Returns the forward and inverse handles for a 2D image block-DCT transform

% Verify parameters
csq_required_parameters(params,'imsize','block_dim');
imsize = params.imsize;
block_dim = params.block_dim;
Psi = DCT2D_Matrix(params.block_dim(1));
psi = @(x) vectorize(col2im(Psi*(im2col(reshape(x,imsize), ...
  block_dim, 'distinc')), block_dim, imsize, 'distinct'));
invpsi = @(x) vectorize(col2im(Psi'*(im2col(reshape(x,imsize), ...
  block_dim, 'distinc')), block_dim, imsize, 'distinct'));


function [psi invpsi] = xform_dct2d(params)
% Returns the forward and inverse handles for a 2D image DCT transform

% Verify parameters
csq_required_parameters(params,'imsize');

psi = @(x) vectorize(dct2(reshape(x,params.imsize)));
invpsi = @(x) vectorize(idct2(reshape(x,params.imsize)));


function [psi invpsi] = xform_dwt2d(params)
% Returns forward and inverse handles for the wavlet transform with specified
% parameters

% Verify required parameters are included
csq_required_parameters(params,'L','imsize');

% Variables
L = params.L;
num_rows = params.imsize(1);
num_cols = params.imsize(2);

% Set wavelet filters
[af sf] = farras;

% Set the function handles
psi = @(x) csq_dwt_cell2vec(dwt2D(reshape(x,[num_rows num_cols]),L,af));
invpsi = @(x) vectorize(idwt2D(csq_dwt_vec2cell(x,num_rows,num_cols,L),L,sf));

function [psi invpsi] = xform_ddwt2d(params)
% Returns forward and inverse handles for the wavlet transform with specified
% parameters

% Verify required parameters are included
csq_required_parameters(params,'L','imsize');

% Variables
L = params.L;
num_rows = params.imsize(1);
num_cols = params.imsize(2);

% Set wavelet filters
[Faf, Fsf] = FSfarras;
[af, sf] = dualfilt1;

% Set the function handles
psi = @(x) csq_ddwt_cell2vec(cplxdual2D(reshape(x,[num_rows num_cols]),L,Faf,af));
invpsi = @(x) vectorize(icplxdual2D(csq_ddwt_vec2cell(x,num_rows,num_cols,L),L,Fsf,sf));


%-----------
function v = vectorize(y)
	v = y(:);









