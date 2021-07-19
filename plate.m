clear;
close all;
%1 ��ȡͼ��
rawPhoto = imread('plate3.jpg');
figure,imshow(rawPhoto),title('ԭʼͼ��');

%2 ת��Ϊ�Ҷ�ͼ
PhotoGray = rgb2gray(rawPhoto);
figure,imshow(PhotoGray),title('ԭʼ�Ҷ�ͼ��');

%3 ����һ�ξ�ֵ�˲�������û��Ҫ������
aaa=fspecial('average',[3,3]);%3*3��ֵ�˲�
filter=imfilter(PhotoGray,aaa);
figure,imshow(filter),title('�˲���ͼ��');

%4 ͼ����ǿ�������ԻҶ�ͼ���п��������ȸ�ʴ�����ͣ�����ñ���
s = strel('disk',13);
backGray = imopen(filter,s);
figure,imshow(backGray);title('����');

%5 ͼ����ǿ�������õõ��ľ�ֵ�˲�ͼ��ȥ���������ͼ�����Ծ�����ɸѡ����������
SubPhoto = imsubtract(filter, backGray);
figure,imshow(SubPhoto);title('��ǿ��ͼ��');

%6 ʹ��roberts���ӽ��б�Ե��⣬һ��������ǳ������򣬺�Ҳ�м������д���
edgePhoto=edge(SubPhoto,'roberts');%��Ե���
figure;imshow(edgePhoto);title('��Ե���');

%7 �и�ʴ�����Ծ�����ɸѡ���������򣨳����������ߣ�
se=[1;1;1];%�и�ʴ���ӣ���ʴ���ӵ���״����Ҫ
erodePhoto=imerode(edgePhoto,se);%�˸�ʴ�ɽ��ǳ��������������Ϣ��ʴ��
figure;imshow(erodePhoto);title('��ʴͼ��');

%8 �趨���αջ����ӣ�ʹ�ִ������ܹ����󣬱��ں���ɸѡ
se1=strel('rectangle',[15,25]);%���αջ�����
closePhoto1=imclose(erodePhoto,se1);%�ջ����� ��Ҫѡ��������
figure;imshow(closePhoto1);title('�ջ�����')

%9 ��ͼ��������Ͳ�����ʹ�ִ������ܱ����΢��һЩ
sel2 = strel('rectangle',[3,3]);
bg2 = imdilate(closePhoto1,sel2);
figure;imshow(bg2);title('���Ͳ���');

%10 ɾ����ͨ��������Ƚ�С�ģ���������Ҫ�Ľϴ��������ɾ����С�Ŀ��Ծ��������½ϴ��������
platePhoto=bwareaopen(closePhoto1,1500);%����ͨ�����С��1500���ص�����ɾ�����˷�����Ϊ�˰ѳ��������������ɾ��
figure,imshow(platePhoto);title('ɾ����С��ͨ����');

%11 ���ͼƬ��С�������������к��е��ܶ��������Ƿ��ǳ�������
[y,x,z]=size(platePhoto);
i6=double(platePhoto);
Y1=zeros(y,1);

%12 ͳ�������أ���ó�����������
for ii=1:y%ͳ��ÿһ�е�����ֵΪ1�ĸ���
    for jj=1:x
        if(i6(ii,jj,1)==1)
            Y1(ii,1)=Y1(ii,1)+1;
        end
    end
end
[temp,MaxY]=max(Y1);%tempΪY1�����ֵ��MaxYΪ�����ڵ�����

%�����ϱ߽�
PY1=MaxY;
while((Y1(PY1,1)>=50)&&(PY1>1))
    PY1=PY1-1;
end
%�����±߽�
PY2=MaxY;
while((Y1(PY2,1)>=50)&&(PY2<y))
    PY2=PY2+1;
end

%13 ͳ�������أ���ó�����������
X1=zeros(1,x);
for jj=1:x%ͳ��ÿһ�е�����ֵΪ1�ĸ�����ֻͳ�Ƴ������±߽�֮���������
    for ii=PY1:PY2
        if(i6(ii,jj,1)==1)
            X1(1,jj)=X1(1,jj)+1;
        end
    end
end
%������߽�
PX1=1;
while((X1(1,PX1)<15)&&(PX1<x))
    PX1=PX1+1;
end
%�����ұ߽�
PX2=x;
while((X1(1,PX2)<15)&&(PX2>PX1))
    PX2=PX2-1;
end
PX1=PX1 - 1;
PX2=PX2 + 1;

%14 ��������õ��ĳ������ұ߽�����±߽����ȷ����������
dw=rawPhoto(PY1:PY2,PX1:PX2,:);%��ó�������
figure,imshow(dw);title('ԭͼ��������')

dw = imresize(dw,[100,314]);

%15 �������ǶԳ���������ж�ֵ���Լ��ָ�
binary = im2bw(dw);
figure; imshow(binary);

dw=binary;
[y1,x1,z1]=size(dw);
I3=double(dw);
for i=2:y1-1                %����  
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

binary = binary(:,10:end-10);   %����֮ǰ�����а��ճ��ƹ�����resize�������ⶨ�����Ʊ߿��ô˷������������г�

sel2 = strel('rectangle',[1,1]);
binary = imclose(binary,sel2);

binary=bwareaopen(binary,135);%����ͨ�����С��135���ص�����ɾ�����˷�����Ϊ�˰ѳ��Ƶĵ�ɾ��
figure,imshow(binary);title('ɾ����С��ͨ����');



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
  while (((X1(1,Px1)>=3)&&(Px1<x1))||((Px1-Px0)<25))    % Px1 - Px0 < 25 Ϊ�˱�֤��Щ�ֻᱻʶ��������ģ����紨����
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
  path = sprintf('%d.jpg',i);% i����̬�ļ���
  imwrite(mat2gray(Z), path);
  subplot(3,8,i+16);
  imshow(Z);
 Px0=Px1;
end
