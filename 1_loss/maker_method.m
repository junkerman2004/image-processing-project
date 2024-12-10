function [out_img] = maker_method(I,J,seed_x,seed_y,gray_value,threshold)  
% GROWING: 实现种子生长算法  
%  
% 输入:  
%   I - 输入图像（灰度图像）  
%   J - 与图像I大小相同的逻辑掩码，初始化为0  
%   seed_x, seed_y - 种子点的x和y坐标  
%   gray_value - 种子点的灰度值（或参考灰度值）  
%   threshold - 灰度值差异的阈值，用于确定哪些像素与种子点相似  
%  
% 输出:  
%   out_img - 更新后的掩码，其中包含了所有通过种子生长算法标记的像素点  
  
%% 初始化掩码  
[M,N] = size(I); % 获取图像I的大小  
  
J(seed_x,seed_y) = 1; % 在掩码J中，将种子点(seed_x, seed_y)设置为1  
  
seedx_list = [seed_x]; % 初始化种子点x坐标列表  
seedy_list = [seed_y]; % 初始化种子点y坐标列表  
  
%% 生长过程  
while isempty(seedx_list)==0 % traverse current seeds
    if (seedx_list(1)-1)>1&&(seedx_list(1)+1)<M&&(seedy_list(1)-1)>1&&(seedy_list(1)+1)<N % 3*3neighbor in img
        for u=-1:1 % one seed -- 8 neighbor growing
            for v=-1:1
                if J(seedx_list(1)+u,seedy_list(1)+v)==0 && abs(I(seedx_list(1)+u,seedy_list(1)+v)-gray_value)<=threshold
                    J(seedx_list(1)+u,seedy_list(1)+v)=1; % this piont in mask = 1
                    seedx_list(end+1)=seedx_list(1)+u;    % new seed stack_in
                    seedy_list(end+1)=seedy_list(1)+v;
                end
            end
        end
    else % seed is border，with no need for grow
        J(seedx_list(1)+u,seedy_list(1)+v)=1; % this piont in mask = 1
    end
   

    seedx_list(1) = [];  
    seedy_list(1) = [];  
      
    % 在实际修正代码中，由于我们已经指出了上述添加和移除方式的错误，  
    % 所以这里不需要再执行任何移除操作（因为根本没有正确添加新种子点）。  
    % 正确的做法应该是在处理完当前种子点的所有邻域后，直接从队列中取出下一个种子点进行处理。  
  
end  
  
out_img = J; % 输出更新后的掩码  
end