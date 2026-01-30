-- 键刃使·幻影 (Rank 5)
function c100044.initial_effect(c)
	-- 超量召唤
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x208),5,2)

	-- ①：削额外 (去除1素材)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100044,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100044) -- HOPT
	e1:SetCost(c100044.rmcost)
	e1:SetTarget(c100044.rmtg)
	e1:SetOperation(c100044.rmop)
	c:RegisterEffect(e1)

	-- ②：无效并拉索拉 (送墓 + 自肃)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100044,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100044+100) -- HOPT
	e2:SetCondition(c100044.negcon)
	e2:SetCost(c100044.negcost)
	e2:SetTarget(c100044.negtg)
	e2:SetOperation(c100044.negop)
	c:RegisterEffect(e2)
end

-- 关联卡片ID
local CARD_SORA = 100000

----------------------------------------------------------------
-- ① 削额外
----------------------------------------------------------------
function c100044.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function c100044.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end

function c100044.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local sg=g:RandomSelect(tp,1)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
end

----------------------------------------------------------------
-- ② 无效并拉人 + 墓地封锁
----------------------------------------------------------------
function c100044.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) 
		and Duel.IsChainNegatable(ev)
end

function c100044.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 必须持有素材 且 可解放
	if chk==0 then return c:GetOverlayCount()>0 and c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function c100044.sora_filter(c,e,tp)
	-- 卡组·手卡
	return c:IsCode(CARD_SORA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100044.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function c100044.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 拉索拉
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsExistingMatchingCard(c100044.sora_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) 
			and Duel.SelectYesNo(tp,aux.Stringid(100044,2)) then
			
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c100044.sora_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end

	-- 【自肃逻辑】这个效果发动后，直到回合结束自己不能从墓地把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c100044.splimit) -- 注意这里也改成了 c100044
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c100044.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 限制从墓地特召
	return c:IsLocation(LOCATION_GRAVE)
end