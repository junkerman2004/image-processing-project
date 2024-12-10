%202200171008 kai zhang
%这是一个降噪前按照比例调整图片大小的程序

I = imread('../0_imgs/img2.jpg');  
J= imread('../0_imgs/Penguins.jpg');
originalSize = size(I);
originalWidth = originalSize(2);
originalHeight = originalSize(1);
targetWidth = 1024;
targetHeight = 768;
scaleFactorWidth = targetWidth / originalWidth;
scaleFactorHeight = targetHeight / originalHeight;

% 选择较小的缩放因子以保持比例
scaleFactor = min(scaleFactorWidth, scaleFactorHeight);
%这段代码首先计算了宽度和高度的缩放因子，
% 然后选择了较小的缩放因子以保持图像的比例。接着，使用 imresize 函数按照这个缩放因子调整图像大小。
% 最后，显示并保存调整后的图像。
% 计算新的尺寸
newWidth = round(originalWidth * scaleFactor);
newHeight = round(originalHeight);

% 调整图像大小
resizedImage = imresize(I, [newHeight, newWidth]);
subplot(1, 2, 1);
imshow(I);
title('Original Image');

subplot(1, 2, 2);
imshow(resizedImage);
title('Resized Image');

% 如果需要保存调整后的图像
imwrite(resizedImage, 'resized_image.jpg');  % 替换 'resized_image.jpg' 为您想要保存的文件名