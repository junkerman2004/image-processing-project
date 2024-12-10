%% 202200171008 kai zhang%% introduction
% 方法：用于图像去噪的总方向变化
% ArXiv链接：https://arxiv.org/abs/1812.05023
% 参考代码：https://github.com/simoneparisotto/TDV-for-image-denoising

% 注意：此代码处理图像大约需要10分钟

clear
close all
clc

addpath ./dataset
addpath ./lib
addpath ./lib/TDV
addpath ./lib/structure_tensor
addpath ./lib/operators
addpath ./lib/lib_Jan
addpath ./lib/plots/export_fig-master/
addpath ./lib/plots

%% SELECT IMAGE (here is noisy img)
fileimage = 'penguins.jpg';

%% GET PARAMETERS
[params,lambda,b,eta,s,r, pn] = get_parameters(fileimage);

%% LOAD CLEAN IMAGE
u = im2double(imread(fileimage));
% imshow(u);
%% load the noisy img
unoise = im2double(imread('penguins.jpg'));
PSNR = zeros(numel(lambda),numel(eta),numel(b),numel(s),numel(r));

%% denoise
params.b = b{1};
params.lambda = lambda(1);
params.eta    = eta(1);
params.sigma = [s(1), 1]; % V2
params.rho   = [r(1), 1];

% core denoise process
fprintf("start denoising\nIt takes about 10 minitues\n");
[udenoise, v, TDVtime, PSNR(1,1,1,1,1)] = tdv_denosing(unoise,params,u);
%% This method refers to https://arxiv.org/abs/1812.05023

imshow(udenoise);
imwrite(udenoise, 'denoised02.png');