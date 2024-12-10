%% (Higher-order) Total directional variation for image denoising


%202200171008 kai zhang

% [u, v, time, varargout] = tdv_denoising(unoise,params,varargin)
%


% Input:
% unoise       = noisy image
% params       = parameters from get_parameters
% varargin{1}  = ground truth image
%
% Output:
% u            = denoised image
% v            = vector field
% time         = cpu time elapsed
% varargout{1} = PSNR (if varargin{1} = unoise)


function [u, v, TDVtime, varargout] = tdv_denoising(unoise,params,varargin)

% measure time
TDVtime = cputime;

% size of the image
u = unoise;
[m,n,c] = size(u);

% check if a clean image is available
flag_psnr = 0;
if nargin==3
    uorig = varargin{1};
    flag_psnr = 1;
else
    uorig = NaN(m,n,c);
end

% CREATE STAGGERED GRIDS for vector fields
location = get_location(m,n);

% COMPUTE GRADIENT OPERATOR
u = padarray(u,[1 1,0],'replicate','both');
params.boundary_u = 'end';
[D1,D2] = gradmat(u,params.boundary_u);

% STORE ORIGINAL CORRUPTERD IMAGE
xnoise = u;

% CREATE A STACK OF SIGMAs AND RHOs FOR THE MULTIPLE TEST OPTION, if any
switch params.update_v_iter
    case 1
        sigma_stack = params.sigma;
        rho_stack   = params.rho;
    otherwise
        stack       = @(r,params) (r(end)-r(1))*max( (0:params.update_v_iter-1)./(params.update_v_iter-1), 0) + r(1);
        sigma_stack = stack([params.sigma(1),params.sigma(2)],params);
        rho_stack   = stack([params.rho(1),params.rho(2)],params);
end

%% START ALGORITHM

for ii = 1:params.update_v_iter % iterates the procedure, if you wish
    
    %% COMPUTE THE VECTOR FIELD v
    switch params.compute_field
        case 'v1'
            sigma = params.sigma;
            rho   = params.rho;
            v = structure_tensor(uorig,sigma,rho,D1,D2,params,location);      % from ground truth image
        case 'v2'
            sigma = sigma_stack(ii);
            rho   = rho_stack(ii);
            if size(u,3)>1
                [v, params.b] = structure_tensor(rgb2gray(u(2:end-1,2:end-1,:)),sigma,rho,D1,D2,params,location);
            else
                [v, params.b] = structure_tensor(u(2:end-1,2:end-1,:),sigma,rho,D1,D2,params,location);
            end
    end
    
    
    %% COMPUTE THE DERIVATIVE OPERATOR OF ORDER Q FOR EACH Q, WEIGHTED BY M
    % compute averaging operators to match derivatives on cell centres
    B  = compute_average_order(m+2,n+2); % move D^Q on cell centres
    Be = speye((m+2)*(n+2),(m+2)*(n+2)); % keep on D^k u position at k-th derivative
    Br = speye((m-1)*(n-1),(m-1)*(n-1)); % keep on cell centres
    % NB the transfer operator to move the derivative of v back to
    % cell centres is not yet implemented
    
    %% BUILD STANDARD MATRICES and MCAL for each order
    [LR,I]  = build_M(v,params.b);
    Mcal{1} = {LR};
    Mcal{2} = {I,LR};
    Mcal{3} = {I,I,LR};
    
    %% BUILD Wcal (transfer operator) for each order
    Wcal{1} = {B{1}};
    Wcal{2} = {{Be,Be},B{2}};
    Wcal{3} = {{Be,Be},{Be,Be,Be,Be},B{3}};
    
    Kcal{1} = MD(u,Mcal{1},Wcal{1},D1,D2,location);
    Kcal{2} = MD(u,Mcal{2},Wcal{2},D1,D2,location);
    Kcal{3} = MD(u,Mcal{3},Wcal{3},D1,D2,location);
    
    %% COMPUTE SADDLE-POINT OPERATORS AND PROX
    % F:= (lamdba/eta)*TDV  is the vectorial soft thresholding.
    K         = @(u,params) Ku(Kcal,u,params);
    KS        = @(y,q)      divMq(y,Mcal{q},Wcal{q},D1,D2,location);
    ProxFS    = @(y,sigma,params) y./max(1,repmat(norms(y,2,3)./params.lambda,1,1,size(y,3)));
    
    % G = 0.5*eta*|| u - u^\diamond||_2^2
    ProxG     = @(x,u,tau)( x+tau*params.eta*u )/( 1+tau*params.eta );
    
    options.niter  = params.maxiter;
    
    %% PRIMAL-DUAL SCHEME
    for kk = 1:size(u,3)
        if flag_psnr
            u(:,:,kk) = perform_primal_dual(xnoise(:,:,kk), params, K, KS, ProxFS, ProxG, options,uorig(:,:,kk));
        else
            u(:,:,kk) = perform_primal_dual(xnoise(:,:,kk), params, K, KS, ProxFS, ProxG, options);
        end
    end
    
    if flag_psnr
        psnr_local = psnr(uorig,u(2:end-1,2:end-1,:));
    end                  
    
end

% return values
if flag_psnr
    varargout{1} = psnr_local(end);
end
u    = u(2:end-1,2:end-1,:);

TDVtime = cputime-TDVtime;

end


