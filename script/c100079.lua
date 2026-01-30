-- 链接怪兽 (Link-2)
function c100079.initial_effect(c)
	-- 链接召唤：包含暗属性怪兽的怪兽2只
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,2,c100079.lcheck)

	-- ①：解放自己，检索仪式怪兽 (主动起动效果)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100079,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION) -- 起动效果 = 主动发动
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100079)
	e1:SetCost(c100079.thcost)
	e1:SetTarget(c100079.thtg)
	e1:SetOperation(c100079.thop)
	c:RegisterEffect(e1)

	-- ②：送墓回合的结束阶段，除外检索「χ刃解放」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100079,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,100079+100)
	e2:SetCondition(c100079.thcon2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c100079.thtg2)
	e2:SetOperation(c100079.thop2)
	c:RegisterEffect(e2)
end

-- 关联卡片ID (χ刃解放)
local CARD_CHI_LIBERATION = 100037

-- 链接素材检查
function c100079.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK,lc,sumtype,tp)
end

----------------------------------------------------------------
-- ① 解放检索仪式怪兽
----------------------------------------------------------------
function c100079.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价：解放自己
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function c100079.thfilter1(c)
	-- 必须是：仪式怪兽 + 能加入手卡
	-- 【修改】这里去掉了 c:IsMonster() 改用 TYPE 检查，防止旧核心报错
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function c100079.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果这里返回 false，你在游戏里就点不了这张卡的发动按钮
	if chk==0 then return Duel.IsExistingMatchingCard(c100079.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c100079.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100079.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

----------------------------------------------------------------
-- ② 结束阶段检索
----------------------------------------------------------------
function c100079.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否是本回合进入墓地的
	return c:GetTurnID()==Duel.GetTurnCount() 
end

function c100079.thfilter2(c)
	return c:IsCode(CARD_CHI_LIBERATION) and c:IsAbleToHand()
end

function c100079.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100079.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c100079.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c100079.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end