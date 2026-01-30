--指令魔法-雷击
-- 键刃使的魔法卡 c100061
function c100061.initial_effect(c)
	-- ①效果：破坏1张里侧表示的卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100061,0))  -- 效果文本提示
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c100061.condition)
	e1:SetTarget(c100061.target)
	e1:SetOperation(c100061.operation)
	c:RegisterEffect(e1)
end

-- ①效果的发动条件
function c100061.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x208) or c:IsSetCard(0x209))
end

function c100061.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c100061.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ①效果的目标选择
function c100061.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ①效果的操作：破坏并无效化相同纵列的其他魔法·陷阱卡
function c100061.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local seq=tc:GetSequence()
		Duel.Destroy(tc,REASON_EFFECT)
		-- 如果这张卡在盖放的状态下发动，则无效化相同纵列的其他魔法·陷阱卡
		if bit.band(tc:GetPreviousPosition(),POS_FACEDOWN)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
			e1:SetTarget(c100061.distarget)
			e1:SetLabel(seq)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function c100061.distarget(e,c)
	return c:GetSequence()==e:GetLabel() and c~=e:GetHandler()
end
