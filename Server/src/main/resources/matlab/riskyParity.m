function[w,rpturn]=riskyParity(dataset,datafee,N,window,hold)
%��ȡ����ʲ��������̼�����
%��������Ϊ����,����Ϊ����ʲ����� 
%����:N ��Ȩ�����ͻ��𹹳ɵ����,M ���̶��������ͻ��𹹳ɵ���ϡ� 
% NΪ����ʲ��ĸ���,����Ӧ����,���������ʾ��� 
dataset=dataset(:,1:N);
datafee=datafee(:,1:3);
display(dataset);
display(datafee);
returndata=zeros(length(dataset)-1,N);
for i=1:N
    for j=1:(length(dataset)-1)
        returndata(j,i)=(dataset(j+1,i)-dataset(j,i))/dataset(j,i); 
%returndata (i,j)Ϊ�� i �������j��������� 
    end
end
algow=1/N*ones(N,1);
%�����������������ںͳ����ڹ�ͬ����
%��������һ���� 960 ��������������,������ Ϊ 360,������ 30
%��ÿ 30 ����ݹ�ȥ 360 �������������������Ȩ��,��(960-360)/ 30=20
%Ҳ������һ������Ȩ�صĴ�����
adjust=floor((length(dataset)-window)/hold);
beta=zeros(1:N);
mul=zeros(1:N);
invbeta=zeros(1:N);
w=zeros(adjust,N);
for i=1:adjust
    orignalr=returndata(1+hold*(i-1):window+hold*(i-1),:); 
    algor=orignalr*algow;
    rmatrix=[orignalr,algor]; 
    covmatrix=cov(rmatrix);
    for j=1:N 
        beta(j)=covmatrix(j,N+1)/covmatrix(N+1,N+1); 
        mul(j)=algow(j)*beta(j)-1/N; 
        invbeta(j)=1/beta(j);
    end
    while sqrt(sum(mul.*mul))>0.003
        for j=1:N 
            beta(j)=covmatrix(j,N)/covmatrix(N+1,N+1); 
            mul(j)=algow(j)*beta(j)-1/N; 
            invbeta(j)=1/beta(j);
        end
        algow=invbeta/sum(invbeta); 
        algor=orignalr*algow'; 
        rmatrix=[orignalr,algor]; 
        covmatrix=cov(rmatrix);
        for t=1:N 
            beta(t)=covmatrix(t,N+1)/covmatrix(N+1,N+1); 
            mul(t)=algow(t)*beta(t)-1/N;
        end
    end
    w(i,1:N)=algow; 
    algow=1/N*ones(N,1);
end
%���￪ʼ�������������
%datafeeΪN������ķ��ʣ�ע�������˳�򱣳�һ��
%�ز����ҽ������йܷѡ�����ѡ����۷�������̶ֹ�����, 
%datafee �� Nx3 �ľ���
% datafee=xlsread('d:/fundfee.xls');

for i=1:adjust
    for j=1:N 
    %N ������ 
        dailyret(:,j)=returndata((window+1)+hold*(i-1):(hold+window)+hold*(i-1),j)+ones(hold,1);
        monthlyret(i,j)=prod(dailyret(:,j))-1-sum(datafee(j,:)');
        %�������޳�������ʵó����ڵľ�����
    end
end
rpturn=sum((w.*monthlyret)');
end