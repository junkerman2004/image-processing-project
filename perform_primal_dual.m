function x = perform_primal_dual(x, params, K, KS, ProxFS, ProxG, options,varargin)
% perform_primal_dual - primal-dual algorithm
%
%    [x,R] = perform_admm(x, K,  KS, ProxFS, ProxG, options);
%
%   Solves
%       min_x F(K*x) + G(x)
%   where F and G are convex proper functions with an easy to compute proximal operator,
%   and where K is a linear operator
%
%   Uses the Preconditioned Alternating direction method of multiplier (ADMM) method described in
%       Antonin Chambolle, Thomas Pock,
%       A first-order primal-dual algorithm for convex problems with applications to imaging,
%       Preprint CMAP-685
%
%   INPUTS:
%   ProxFS(y,sigma) computes Prox_{sigma*F^*}(y)
%   ProxG(x,tau) computes Prox_{tau*G}(x)
%   K(y) is a linear operator.
%   KS(y) compute K^*(y) the dual linear operator.
%   options.sigma and options.tau are the parameters of the
%       method, they shoudl satisfy sigma*tau*norm(K)^2<1
%   options.theta=1 for the ADMM, but can be set in [0,1].
%   options.verb=0 suppress display of progression.
%   options.niter is the number of iterations.
%   options.report(x) is a function to fill in R.
%
%   OUTPUTS:
%   x is the final solution.
%   R(i) = options.report(x) at iteration i.
%
%   Copyright (c) 2010 Gabriel Peyre

options.null = 0;
niter  = getoptions(options, 'niter', 100);
theta  = getoptions(options, 'theta', 1);


%%%% ADMM parameters %%%%
sigma = getoptions(options, 'sigma', -1);
tau   = getoptions(options, 'tau', -1);

% INITIALIZATION
if nargin == 8
    xorig = varargin{1};
    psnr_local = zeros(niter,1);
end

if sigma<0 || tau<0
    rr = randn(size(x));
end

Q = numel(params.lambda{:});
index_Q = find(params.lambda{1});

paramslocal = cell(Q,1);
xstar       = cell(Q,1);
y           = cell(Q,1);
Lq          = cell(Q,1);

for q=index_Q
    
    paramslocal{q}        = params;
    paramslocal{q}.order  = params.order(q);
    paramslocal{q}.lambda = params.lambda{1}(q);
    
    xstar{q} = 0;
    y{q}     = 0;
    Lq{q}    = 0;
    
    if sigma<0 || tau<0
        Lq{q} = compute_operator_norm(@(x) KS(K(x,paramslocal{q}),q),rr);
        y{q}  = K(x,paramslocal{q});
    end
    
end

% OPERATOR NORM
L = max(cat(1,Lq{index_Q}));
%L = max([8.^find(params.lambda{1})]);

if params.acceleration
    
    %  ADMM
    tau   = 1/sqrt(L);
    sigma = 1./(tau*L);
    %gamma = 0.5;
    gamma = 0.35*params.eta;
    
else
    sigma = 10;
    tau   = 0.9/(sigma*L);
end

fprintf("there are %d loops\n", niter);

if params.verbose_text
    fprintf('\n  ITER\n');
    fprintf('--------\n');
end

xhat   = x;
xnoise = x;



for iter = 1:niter
    
    xold = x;
    
    % DUAL PROBLEM
    for q=index_Q
        y{q}     = ProxFS( y{q} + sigma*K(xhat,paramslocal{q}), sigma, paramslocal{q});
        xstar{q} = KS(y{q},q);
    end
    
    % PRIMAL PROBLEM
    x = ProxG(  x-tau*sum(cat(3,xstar{index_Q}),3), xnoise, tau);
    
    % EXTRAPOLATION
    xhat = x + theta * (x-xold);
    
    % ACCELERATION
    if params.acceleration
        theta = 1./sqrt(1+2*gamma*tau);
        tau   = theta*tau;
        sigma = sigma/theta;
    end
    
    if nargin == 8
        psnr_local(iter) = psnr(xorig,x(2:end-1,2:end-1));     
        if params.verbose_text && ~mod(iter,10)
            fprintf('   %02d\n',iter )
        end
    else
        fprintf('Denoising in progress...')
    end
    
end

if nargin<8
    fprintf(' done!\n')
end

end