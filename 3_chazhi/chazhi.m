clear; clc;
%% 202200171008 kai zhang
%% 用去噪图像修复缺失图像
DA = imread('../0_imgs/Penguins.jpg');
mask_pic = imread('../0_imgs/mask_pic.png');

mask_pic = im2double(mask_pic);

img1 = imread('../0_imgs/img1.jpg');
denoised = imread('../0_imgs/denoised02.png');

%% 变亮与去噪图像
%hsv=rgb2hsv(denoised);
%hsv(:,:,1)=1.05*hsv(:,:,1);  % hue
%hsv(:,:,2)=1.5*hsv(:,:,2);   % saturability
%hsv(:,:,3)=1.2*hsv(:,:,3);  % brightness
%result=hsv2rgb(hsv);
%result = im2uint8(result);
% 增强图像的颜色
result = imadjust(denoised, [0.24, 0.86], [0, 0.97]); 

mask_final = repmat(mask_pic, [1,1,3]); % 3 通道 (otherwise, only get red channel)

new_img = img1;

zero = mask_final == 1; % white->1, black->0

new_img(zero) = result(zero);




%% 评估
new_img = im2double(new_img);
DA = im2double(DA);
max_pixel=1024*768;

SSIM = ssim(new_img, DA);
IMMSE=immse(new_img,DA);
PSNR= psnr(new_img, DA, max_pixel);
fprintf("SSIM: %f\n", SSIM);
fprintf("IMMSE: %f\n", IMMSE);
fprintf("PSNR: %f\n", PSNR);
%% 展示与保存
imshow(new_img);
imwrite(new_img, '../0_imgs/fixed_img.png');
%% SSIM: 0.999903
