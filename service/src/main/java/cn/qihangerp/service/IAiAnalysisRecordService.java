package cn.qihangerp.service;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.model.entity.AiAnalysisRecord;

public interface IAiAnalysisRecordService {
    void save(AiAnalysisRecord record);
    AiAnalysisRecord getById(Long id);
    PageResult<AiAnalysisRecord> queryPageList(PageQuery query);
}
