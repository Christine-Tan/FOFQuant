function[equalw,equalwreturn,sharpe]=oneDivideN(dataset,datafee,N,window,hold)
%��ȡ����,Ϊ����ʲ��������̼�����,��������Ϊ����,����Ϊ����ʲ�����
%����:N��Ȩ�����ͻ��𹹳ɵ����,M���̶��������ͻ��𹹳ɵ���ϡ� 
% dataset=xlsread('d:/dailysector.xls');
dataset=dataset(:,1:N);
datafee=datafee(:,1:3);
returndata=zeros(length(dataset)-1,N);
for i=1:N
    for j=1:(length(dataset)-1) 
        returndata(j,i)=(dataset(j+1,i)-dataset(j,i))/dataset(j,i);
    end
end
%NΪ����ʲ��ĸ���,���������ʾ��� 
%20�����������������ںͳ����ڹ�ͬ����
%��������һ����960��������������,������Ϊ 360,������30
%��ÿ30����ݹ�ȥ360�������������������Ȩ��,��(960-360)/ 30=20
%Ҳ������һ������Ȩ�صĴ������������������Ҳ��ز⡣
adjust=floor((length(dataset)-window)/hold);
equalw=1/N*ones(adjust,N);
%ע��:equal w�����Ʒ���ƽ���е�w
%ע��,���￪ʼ��������
 for i=1:adjust
     for j=1:N
         dailyret(:,j)=returndata((window+1)+hold*(i-1):(window+hold)+hold*(i-1),j)+ones(hold,1);
         monthlyret(i,j)=prod(dailyret(:,j))-1-sum(datafee(j,:)')/100;
     end
 end
equalwreturn=sum((equalw.*monthlyret)')';
sharpe=adjust((equalwreturn'),hold);
end