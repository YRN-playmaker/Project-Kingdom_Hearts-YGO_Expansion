--心之暗面
function c100013.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c100013.cost)
	e1:SetTarget(c100013.target)
	e1:SetOperation(c100013.activate)
	c:RegisterEffect(e1)
end

-- 记录发动标志
function c100013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end

-- 解放怪兽的条件（必须是表侧、有等级、并且能从卡组或墓地找到匹配怪）
function c100013.costfilter(c,e,tp)
	return c:IsFaceup() and c:GetOriginalLevel()>0 and c:IsSetCard(0x208)
		and Duel.IsExistingMatchingCard(c100013.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetOriginalLevel(),e,tp) and not c:IsAttribute(ATTRIBUTE_DARK) 
end

-- 检查卡组/墓地中是否存在符合条件的怪兽
function c100013.spfilter(c,lv,e,tp)
	return (c:GetOriginalLevel()==lv or c:GetOriginalRank()==lv)
		and c:IsAttribute(ATTRIBUTE_DARK) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,c100013.costfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	local g=Duel.SelectReleaseGroup(tp,c100013.costfilter,1,1,nil,e,tp)
	local lv=g:GetFirst():GetOriginalLevel()
	Duel.Release(g,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c100013.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100013.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


