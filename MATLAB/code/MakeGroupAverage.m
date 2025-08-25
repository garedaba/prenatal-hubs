function [GrpAvg, TotalConns] = MakeGroupAverage(sc_indv_term,thr,conthr)

if nargin < 3
    conthr = .3;
end

MeanConnAll = mean(sc_indv_term>0,3);
TotalConns = sum(sc_indv_term>0,3);
ConsistMat = (MeanConnAll>conthr);
MeanConn = sum(sc_indv_term,3)./TotalConns;
MeanConn(MeanConnAll==0)=0;
MeanConn_totalConnThr = ConsistMat.*MeanConn.*~eye(length(MeanConn));
GrpAvg = strength_threshold(MeanConn_totalConnThr,thr);