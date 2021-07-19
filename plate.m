clear;
close all;
%1 获取图像
rawPhoto = imread('plate3.jpg');
figure,imshow(rawPhoto),title('原始图像');

%2 转换为灰度图
PhotoGray = rgb2gray(rawPhoto);
figure,imshow(PhotoGray),title('原始灰度图像');

%3 进行一次均值滤波，消除没必要的噪声
aaa=fspecial('average',[3,3]);%3*3均值滤波
filter=imfilter(PhotoGray,aaa);
figure,imshow(filter),title('滤波后图像');

%4 图像增强操作，对灰度图进行开操作（先腐蚀后膨胀），获得背景
s = strel('disk',13);
backGray = imopen(filter,s);
figure,imshow(backGray);title('背景');

%5 图像增强操作，用得到的均值滤波图减去开操作后的图，可以尽可能筛选出车牌区域
SubPhoto = imsubtract(filter, backGray);
figure,imshow(SubPhoto);title('增强后图像');

%6 使用roberts算子进行边缘检测，一般检测出的是车牌区域，后也有继续进行处理
edgePhoto=edge(SubPhoto,'roberts');%边缘检测
figure;imshow(edgePhoto);title('边缘检测');

%7 列腐蚀，可以尽可能筛选出竖排区域（车牌左右两边）
se=[1;1;1];%列腐蚀算子，腐蚀算子的形状很重要
erodePhoto=imerode(edgePhoto,se);%此腐蚀可将非车牌区域的噪声信息腐蚀掉
figure;imshow(erodePhoto);title('腐蚀图像');

%8 设定方形闭环算子，使现存区域能够更大，便于后面筛选
se1=strel('rectangle',[15,25]);%方形闭环算子
closePhoto1=imclose(erodePhoto,se1);%闭环运算 需要选择大的算子
figure;imshow(closePhoto1);title('闭环运算')

%9 对图像进行膨胀操作，使现存区域能变得稍微大一些
sel2 = strel('rectangle',[3,3]);
bg2 = imdilate(closePhoto1,sel2);
figure;imshow(bg2);title('膨胀操作');

%10 删除连通区域面积比较小的（车牌是主要的较大面积区域，删除较小的可以尽可能留下较大面积区域）
platePhoto=bwareaopen(closePhoto1,1500);%将连通域面积小于1500像素的区域都删除，此方法是为了把除车牌以外的区域都删除
figure,imshow(platePhoto);title('删除较小连通区域');

%11 获得图片大小，根据像素在行和列的密度来区分是否是车牌区域
[y,x,z]=size(platePhoto);
i6=double(platePhoto);
Y1=zeros(y,1);

%12 统计行像素，获得车牌上下区间
for ii=1:y%统计每一行的像素值为1的个数
    for jj=1:x
        if(i6(ii,jj,1)==1)
            Y1(ii,1)=Y1(ii,1)+1;
        end
    end
end
[temp,MaxY]=max(Y1);%temp为Y1的最大值，MaxY为其所在的行数

%求车牌上边界
PY1=MaxY;
while((Y1(PY1,1)>=50)&&(PY1>1))
    PY1=PY1-1;
end
%求车牌下边界
PY2=MaxY;
while((Y1(PY2,1)>=50)&&(PY2<y))
    PY2=PY2+1;
end

%13 统计列像素，获得车牌左右区间
X1=zeros(1,x);
for jj=1:x%统计每一列的像素值为1的个数，只统计车牌上下边界之间的像素数
    for ii=PY1:PY2
        if(i6(ii,jj,1)==1)
            X1(1,jj)=X1(1,jj)+1;
        end
    end
end
%求车牌左边界
PX1=1;
while((X1(1,PX1)<15)&&(PX1<x))
    PX1=PX1+1;
end
%求车牌右边界
PX2=x;
while((X1(1,PX2)<15)&&(PX2>PX1))
    PX2=PX2-1;
end
PX1=PX1 - 1;
PX2=PX2 + 1;

%14 根据上面得到的车牌左右边界和上下边界可以确定车牌区域
dw=rawPhoto(PY1:PY2,PX1:PX2,:);%求得车牌区域
figure,imshow(dw);title('原图车牌区域')

dw = imresize(dw,[100,314]);

%15 接下来是对车牌区域进行二值化以及分割
binary = im2bw(dw);
figure; imshow(binary);

dw=binary;
[y1,x1,z1]=size(dw);
I3=double(dw);
for i=2:y1-1                %膨胀  
    for j=2:x1-1
        temp=dw(i-1:i+1,j-1:j+1);
        I3(i,j)=max(temp(:));     
    end
end

X1=zeros(1,x1);
for j=1:x1
    for i=1:y1
             if(I3(i,j,1)==0) 
                X1(1,j)= X1(1,j)+1;
            end  
     end       
end

binary = binary(:,10:end-10);   %由于之前代码有按照车牌规格进行resize，经过测定，车牌边框用此方法可以明显切除

sel2 = strel('rectangle',[1,1]);
binary = imclose(binary,sel2);

binary=bwareaopen(binary,135);%将连通域面积小于135像素的区域都删除，此方法是为了把车牌的点删除
figure,imshow(binary);title('删除较小连通区域');



[y1,x1,z1]=size(binary);
I3=double(binary);
X1 = sum(binary);



Px0=1;
Px1=1;
for i=1:7
  while ((X1(1,Px0)<3)&&(Px0<x1))
      Px0=Px0+1;
  end
  Px1=Px0;
  while (((X1(1,Px1)>=3)&&(Px1<x1))||((Px1-Px0)<25))    % Px1 - Px0 < 25 为了保证有些字会被识别成连续的，例如川和浙
      Px1=Px1+1;
      if(Px1>=x1)
          Px1 = x1;
          break; 
      end
  end
  Z=binary(:,Px0:Px1,:);
  
  [r,c] = size(Z);
  TempZero = zeros(1,r);
  for j = 1:(c/3)
    Z = [TempZero',Z];
    Z = [Z,TempZero'];
  end
  Z = imresize(Z,[20,20]);
  path = sprintf('%d.jpg',i);% i代表动态文件名
  imwrite(mat2gray(Z), path);
  subplot(3,8,i+16);
  imshow(Z);
 Px0=Px1;
end
