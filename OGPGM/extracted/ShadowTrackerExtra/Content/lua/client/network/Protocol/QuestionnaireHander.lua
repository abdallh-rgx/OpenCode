
--调查问卷协议
QuestionnaireHander = QuestionnaireHander or
{
    
}

eMsgID = eMsgID or { }

function QuestionnaireHander.send_questionnaire_finished_report_req()
    NetManager.SendPkg(eMsgID.eQuestionnaireProfile)
end

function QuestionnaireHander.on_questionnaire_finished_report_rsp()
    --todo write response code here

end
