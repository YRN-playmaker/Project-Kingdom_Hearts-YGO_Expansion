-- 键刃使 泰拉-赛阿诺德
function c100074.initial_effect(c)
	--① 特殊召唤的不受其他效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c100074.immcon)
	e1:SetValue(c100074.efilter)
	c:RegisterEffect(e1)

	--② 装备暗属性怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100074,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c100074.eqtg)
	e2:SetOperation(c100074.eqop)
	c:RegisterEffect(e2)

	--③ 特召的回合结束阶段送墓
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c100074.regop)
	c:RegisterEffect(e3)
end

--① 只有特殊召唤状态下免疫
function c100074.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c100074.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

--② 选暗属性怪兽（可以选自己也可以选对方）
function c100074.eqfilter(c,ec)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToChangeControler() and c~=ec
end

function c100074.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c100074.eqfilter(chkc,e:GetHandler()) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(function(c) return c100074.eqfilter(c,e:GetHandler()) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,function(c) return c100074.eqfilter(c,e:GetHandler()) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function c100074.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if not Duel.Equip(tp,tc,c,false) then return end

	-- 设置装备限制（装备对象必须是c）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	e0:SetValue(function(e,ec) return ec==e:GetOwner() end)
	tc:RegisterEffect(e0)

	-- 攻击力上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end

--③ 特召的回合结束阶段送墓登记
function c100074.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_SPECIAL) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
