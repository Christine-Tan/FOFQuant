function[w,rpturn,sharpe]=MarketRiskyParity(dataset,windowperiod,holdingperiod,lever)
%��ȡ���ݣ�Ϊ����ʲ��������̼����ݣ���������Ϊ��������һ��Ϊ��Ʊ����ָ�����ڶ���Ϊ��̩��֤5���ծetf
%returndata(j,2)���*5Ϊ5���ܸ˵���˼
for j=1:(length(dataset)-1)
    returndata(j,1)=(dataset(j+1,1)-dataset(j,1))/dataset(j,1);
    returndata(j,2)=(dataset(j+1,2)-dataset(j,2))/dataset(j,2)*lever;
end
%��ʼȨ������Ϊ��Ȩ��
algow=1/2*ones(2,1);
%wΪȨ��������������Ϊ��
w=[];
times=floor((length(dataset)-windowperiod)/holdingperiod);
%{
20�ɻز����������������ںͳ����ڹ�ͬ��������������һ����980�������������ݣ�������Ϊ360��
������30����ÿ30����ݹ�ȥ360�������������������Ȩ�أ�������ȡ����980-360��/30=20,Ҳ������һ������Ȩ�صĴ���
%}
%��360��Ϊ�����ڣ�30��Ϊ�����ڣ�����Э�������
for i=1:times
    orignalr=returndata(1+holdingperiod*(i-1):windowperiod+holdingperiod*(i-1),:);
    algor=orignalr*algow;
    rmatrix=[orignalr,algor];
    covmatrix=cov(rmatrix);
    %����ÿ���ʲ��������ϵ�betaֵ
       for j=1:2
           beta(j)=covmatrix(j,3)/covmatrix(3,3);
           mul(j)=algow(j)*beta(j)-1/2;
           invbeta(j)=1/beta(j);
       end
       %�ж��Ƿ��˳���������С��0.003ʱ�˳�������0.003�Լ�ȡ����ֵԽС������Խ��
       while sqrt(sum(mul.*mul))>0.003;
           for j=1:2
               beta(j)=covmatrix(j,3)/covmatrix(3,3);
               mul(j)=algow(j)*beta(j)-1/2;
               invbeta(j)=1/beta(j);
           end
           %������0.003ʱ�����������õ��µ�wֵ���������µ�Э�����������ѭ��
           algow=invbeta/sum(invbeta);
           algor=orignalr*algow';
           rmatrix=[orignalr,algor];
           covmatrix=cov(rmatrix);
           for t=1:2
               beta(t)=covmatrix(t,3)/covmatrix(3,3);
               mul(t)=algow(t)*beta(t)-1/2;
           end
       end
       w(i,1:2)=algow;
       algow=1/2*ones(2,1);
end
%�����Ʊ����Ȩ��Ϊ������Ϊ����Ϊ0Ȩ��
for i=1:times
    if w(i,1)<0;
        w(i,1)=0;
        w(i,2)=1;
    end
end
%����������ʾ����ÿ30����������ʾ���30Ϊ�����ڣ�
for i=1:times
    for j=1:2
        dailyret(:,j)=returndata((windowperiod+1)+holdingperiod*(i-1):(windowperiod+holdingperiod)+holdingperiod*(i-1),j)+ones(holdingperiod,1);
        monthlyret(i,j)=prod(dailyret(:,j))-1;
    end
end
%�������������ó���Ȩ������w���������ʾ���������ÿ30��������ʾ���30Ϊ�����ڣ�
rpturn=sum((w.*monthlyret)')';
sharpe=calSharpe((rpturn'),0.037,holdingperiod);    
end