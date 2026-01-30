--键刃使 索拉rage form（最终优化版）
function c100008.initial_effect(c)
	c:EnableReviveLimit()
	--特殊召唤程序（不变）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c100008.spcon)
	e1:SetOperation(c100008.spop)
	c:RegisterEffect(e1)
	
	--支付1000LP破坏1张卡（不变）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100008,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c100008.descost)
	e2:SetTarget(c100008.destg)
	e2:SetOperation(c100008.desop)
	c:RegisterEffect(e2)

	--注册全局检测效果（无连锁，无时点，强制结算）
	if not c100008.global_check then
		c100008.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_PHASE+PHASE_END)
		ge:SetCountLimit(1)
		ge:SetOperation(c100008.global_clop)
		Duel.RegisterEffect(ge,0)
	end
end

--特殊召唤条件函数
function c100008.spfilter(c,ft,tp)
	return (c:IsCode(100000) or c:IsCode(100001))
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
		and (c:IsControler(tp) or c:IsFaceup())
end
function c100008.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.CheckReleaseGroup(tp,c100008.spfilter,1,nil,ft,tp)
end
function c100008.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,c100008.spfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end

--支付1000LP破坏1张卡（费用及目标）
function c100008.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>4000 and Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c100008.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c100008.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local ct=Duel.GetFlagEffect(tp,10000810)
		if ct==0 then
			Duel.RegisterFlagEffect(tp,10000810,RESET_PHASE+PHASE_END,0,1)
			Duel.SetFlagEffectLabel(tp,10000810,1)
		else
			local label=Duel.GetFlagEffectLabel(tp,10000810)
			Duel.SetFlagEffectLabel(tp,10000810,label+1)
		end
	end
end

--全局无时点强制清场效果（完整实现）
function c100008.global_clop(e,tp,eg,ep,ev,re,r,rp)
	local label_p1=Duel.GetFlagEffectLabel(0,10000810)
	local label_p2=Duel.GetFlagEffectLabel(1,10000810)
	--任意玩家满足条件即清场
	if (label_p1 and label_p1>=2) or (label_p2 and label_p2>=2) then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_DESTROY) --规则处理，无时点、不入连锁
	end
	--重置标记，下一回合重新计算
	Duel.ResetFlagEffect(0,10000810)
	Duel.ResetFlagEffect(1,10000810)
end


