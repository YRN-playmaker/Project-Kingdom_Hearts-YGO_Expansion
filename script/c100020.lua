--键刃使 索拉Master Form
function c100020.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,99,c100020.lcheck)
	c:EnableReviveLimit()
--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,100020)
	e1:SetDescription(aux.Stringid(100020,0))
	e1:SetCondition(c100020.hspcon)
	e1:SetOperation(c100020.hspop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c100020.atkval)
	c:RegisterEffect(e2)
--indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c100020.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)

end
--e1
function c100020.hspfilter(c,ft,tp)
	return c:IsSetCard(0x208) and c:IsLevel(8) and not c:IsCode(100001)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function c100020.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.CheckReleaseGroup(tp,c100020.hspfilter,1,nil,ft,tp)
end
function c100020.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,c100020.hspfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
--e0
function c100020.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x208)
end
--e2
function c100020.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
function c100020.indtg(e,c)
	return c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end