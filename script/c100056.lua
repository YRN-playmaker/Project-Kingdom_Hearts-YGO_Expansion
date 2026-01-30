-- DS 忘却之城
-- ID: 100056
function c100056.initial_effect(c)
	-- 发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：攻击 Cost（改为：回到卡组最下方）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1) -- 影响双方
	e1:SetCost(c100056.atkcost)
	e1:SetOperation(c100056.atkop)
	c:RegisterEffect(e1)

	-- ②：送墓特招（场地的这张卡送墓 -> 特招维恩图斯）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100056,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c100056.spcon)
	e2:SetTarget(c100056.sptg)
	e2:SetOperation(c100056.spop)
	c:RegisterEffect(e2)

	-- ③：反击效果（对方效果让额外卡组卡片送墓 -> 除外对方卡顶）
	-- 1回合只能使用1次
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100056,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,100056) -- 添加了HOPT限制
	e3:SetCondition(c100056.ctrcon)
	e3:SetTarget(c100056.ctrtg)
	e3:SetOperation(c100056.ctrop)
	c:RegisterEffect(e3)
end

-------------------------------------------------------------------------
-- ① 攻击 Cost：回到卡组最下方
-------------------------------------------------------------------------
function c100056.atkcost(e,c,tp)
	-- 检查手卡是否有可以返回卡组的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
end

function c100056.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,100056)
	-- 提示玩家选择
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		-- 参数说明：(对象, 玩家, 目的地区域SEQ, 原因)
		-- SEQ_DECKBOTTOM 代表回到卡组最下方
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
end

-------------------------------------------------------------------------
-- ② 送墓特招 逻辑
-------------------------------------------------------------------------
function c100056.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 必须是表侧表示且从场地区域送去墓地
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end

function c100056.spfilter(c,e,tp)
	-- 检查 ID 是否为 100032 (维恩图斯)
	return c:IsCode(100032) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function c100056.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100056.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c100056.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c100056.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

-------------------------------------------------------------------------
-- ③ 反击效果 逻辑
-------------------------------------------------------------------------
function c100056.ctrfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_EXTRA) -- 必须是从【额外卡组】送去墓地
		and c:IsControler(tp)				   -- 是【自己】的卡
		and c:IsReason(REASON_EFFECT)		   -- 是被【效果】
		and c:GetReasonPlayer()==1-tp		   -- 是被【对方】造成的
end

function c100056.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100056.ctrfilter,1,nil,tp)
end

function c100056.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil,tp,POS_FACEDOWN) 
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end

function c100056.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,1)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end