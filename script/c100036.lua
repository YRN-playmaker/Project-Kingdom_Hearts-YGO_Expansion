-- 无知 邦尼塔斯
function c100036.initial_effect(c)
	-- 规则上也当作「键刃使」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x208)
	c:RegisterEffect(e0)

	-- 特殊召唤（对方场上解放）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100036,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,100036)  -- ①效果1回合1次
	e1:SetCondition(c100036.spcon)
	e1:SetTarget(c100036.sptg)
	e1:SetOperation(c100036.spop)
	c:RegisterEffect(e1)

	-- 离场伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100036,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,100036+100)  -- ②效果1回合1次
	e2:SetOperation(c100036.damop)
	c:RegisterEffect(e2)

	-- 仪式解放 -> 除外手卡
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCondition(c100036.rmcon)
	e3:SetOperation(c100036.rmop)
	c:RegisterEffect(e3)
end

-- ① 有光属性怪兽存在
function c100036.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_LIGHT)
end

function c100036.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c100036.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 and Duel.Release(g,REASON_COST)>0 and c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)~=0 then
			-- 这个方法特殊召唤的这张卡从场上离开时里侧表示除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetCondition(c100036.rmcon2)
			c:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_REMOVE_TYPE)
			e2:SetValue(TYPE_TOKEN)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2,true)
		end
	end
end

function c100036.rmcon2(e)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) or c:IsReason(REASON_RELEASE) or c:IsReason(REASON_RETURN)
end

-- ② 离场时造成伤害
function c100036.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,100036)
	Duel.Damage(tp,500,REASON_EFFECT)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end

function c100036.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end

function c100036.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,100036)
	local p=e:GetHandler():GetPreviousControler()
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g>0 then
		local sg=g:RandomSelect(p,1)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

