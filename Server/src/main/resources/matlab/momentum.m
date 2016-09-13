function[momw,momreturn,sharpe]=momentum(dataset,datafee,N,window,hold)
%datasetΪ����ʲ��������̼�����,��������Ϊ����,����Ϊ����ʲ����� ����:N��Ȩ�����ͻ��𹹳ɵ����,M���̶��������ͻ��𹹳ɵ���ϡ�
dataset=dataset(:,1:N);
datafee=datafee(:,1:3);
returndata=zeros(length(dataset)-1,N);
for i=1:N
    for j=1:(length(dataset)-1)
        returndata(j,i)=(dataset(j+1,i)-dataset(j,i))/dataset(j,i);
    end
end
%NΪ����ʲ��ĸ���,����Ӧ����,���������ʾ���
times=floor((length(dataset)-window)/hold);
momw=zeros(times,N);
for i=1:times
    meanret(i,:)=mean(returndata(1+hold*(i-1):window+hold*(i-1),:));
    smeanret(i,:)=sort(meanret(i,:),'descend');
    num(i)=size(find(smeanret(i,:)>=smeanret(i,min(N,5))),2);
    %������л��𴰿���ƽ�������ʽ�������,Ȼ���ʽ�ƽ���������������ʷƽ��ii��ǰ5λ�Ļ���,��ǰ5�����Ȩ�ؾ�Ϊ1/5.�����ؾ�������size(A,2) i
    momw(i,find(meanret(i,:)>=smeanret(i,num(i))))=1/num(i); 
    %ע��:����momw������ƽ����w
end
%ע��,���￪ʼ��������
for i=1:times
     for j=1:N
          dailyret(:,j)=returndata((window+1)+hold*(i-1):(window+hold)+hold*(i-1),j)+ones(hold,1);
          monthlyret(i,j)=prod(dailyret(:,j))-1-sum(datafee(j,:)'/100); 
     end
end
momreturn=sum((momw.*monthlyret)')';
sharpe=calSharpe((momreturn'),0.037,hold);
%ע��,����momreturn������ƽ�����rpturn ������ͬ
end