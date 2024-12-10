%% region growing get the broken area (mask)
%% 202200171008 Kai Zhang
%% 图像加工

I = imread('../0_imgs/img1.jpg');  
figure;  
imshow(I);  
title('请自上而下点击五个种子点（右键结束选择）');  
  
if isinteger(I)  
    I = im2double(I); % 转为double类型  
end  
I = rgb2gray(I); % 转为灰度图像  
  
%% mouse interaction get four seeds  
[M, N] = size(I);  
  
% 使用ginput获取四个点的坐标  
[x, y] = ginput(5); % 用户通过鼠标点击选择四个点，右键结束选择  
  
% 显示选择的点  
hold on;  
plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % 用红色圆圈标记选择的点  
hold off;  
  
% 提取种子点的灰度值（这里假设已经正确获取了四个点）  
seed_x=round(x); % round() get closest integer
seed_y=round(y); % position is integer
seed_value = zeros(1, 5);  
for i = 1:5  
    seed_value(i) = I(seed_y(i), seed_x(i)); % 注意y和x的顺序，MATLAB是列优先  
end  
  
% 显示种子点的灰度值  
disp('种子点的灰度值：');  
disp(seed_value);  
%自上而下的种子灰度阈值
threshold=[0.25,0.08,0.10,0.015,0.29]; %数字越大区域越大
%特别注意：有时候对于图像的补充如果以结构像相似性系数为标准，可以相比确实区域搞的大一些
% 创建一个零矩阵J）  
J = zeros(M, N);  
%% 开始区域种子种植
for i=1:1:5
    J(seed_y(i),seed_x(i))=1; % seeds is 1
    J = maker_method(I,J,seed_y(i),seed_x(i),seed_value(i),threshold(i)); % 调用设置的图像生成函数
end


subplot(1,2,1),imshow(I);
title("original image")
subplot(1,2,2),imshow(J);
title("mask image")
imwrite(J,'../0_imgs/mask_pic.png');
%% end
fprintf("THE END!")