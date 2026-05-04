# GrK Rotas - Sistema Avançado de Coleta e Grupos

Sistema de rotas de coleta (farm) moderno e interativo, focado em otimizar o tempo do jogador e incentivar o roleplay em equipe. O sistema permite que o jogador selecione múltiplos itens para farmar simultaneamente e conta com um sistema nativo de criação de grupos com bônus de coleta.

## 📌 Características
- **Interface UI/UX Premium:** Design minimalista e responsivo (Dark/Clean style).
- **Farm Multi-Itens:** O jogador pode selecionar até 5 itens diferentes (configurável) para coletar na mesma rota.
- **Sistema de Grupos:** Jogadores podem criar grupos, convidar amigos via Passaporte (ID) direto pela NUI e fazer a rota juntos.
- **Bônus de Coleta:** Fazer a rota em grupo concede bônus de itens extras na coleta (configurável para VIPs).
- **Rotas Dinâmicas:** O sistema sorteia aleatoriamente os trajetos configurados para evitar que o farm seja sempre no mesmo local.
- **Notificações Integradas:** Avisos na tela (Toast NUI) e convites interativos com botões de aceitar/recusar.

## 📦 Dependências
- `vrp` (Framework base)

## 🛠️ Instalação

1. Coloque a pasta do script na sua base (resources). *O nome da pasta não interfere no funcionamento.*
2. Abra o arquivo `config.lua` e configure os locais das rotas, limites de itens e grupos VIP.
3. Adicione o script no seu `server.cfg`:
   ```text
   ensure nome_da_pasta
Certifique-se de que os itens listados no config.lua existam no inventário da sua base e que as imagens deles estejam na pasta de imagens do seu inventário.

🎒 Itens Necessários
Para que o script funcione corretamente sem erros no F8, os seguintes itens devem estar cadastrados no seu inventário (banco de dados ou items.lua). Você pode alterar, remover ou adicionar novos no config.lua:

Materiais Básicos:

plastic (Plástico)

copper (Cobre)

rubber (Borracha)

glass (Vidro)

aluminum (Alumínio)

paper (Papel)

Componentes Metálicos & Peças:

metalspring (Mola Metálica)

scrapmetal (Sucata Metálica)

sheetmetal (Chapa Metálica)

weaponparts (Peças de Arma)

Químicos & Explosivos:

lithium (Lítio)

tinta (Tinta)

gunpowder (Pólvora)

sulfuric (Ácido Sulfúrico)

alcohol (Álcool)

acetone (Acetona)

explosives (Explosivos)

saline (Soro Fisiológico)

Armamento (Corpos e Cápsulas):

riflebody, smgbody, pistolbody

capsularifle, capsulasmg, capsulapistol

selo (Selo)

⚙️ Adaptação de Funções do vRP
Este script foi desenvolvido utilizando a sintaxe mais recente do vRP (Creative/Network). Se você utiliza vRPex ou uma base mais antiga, precisará adaptar as seguintes funções no arquivo core.lua (server-side):

1. Pegar Passaporte / ID do Jogador
No script: vRP.Passport(source)
Como é no vRPex: vRP.getUserId(source)

2. Pegar a Source (ID da Sessão) pelo Passaporte
No script: vRP.Source(passport)
Como é no vRPex: vRP.getUserSource(passport)

3. Pegar Nome do Jogador
No script: vRP.GetName(passport)
Como é no vRPex:
Você precisará buscar a identidade do jogador. Exemplo:

Lua
local identity = vRP.getUserIdentity(passport)
if identity then
    return identity.name .. " " .. identity.firstname
else
    return "Jogador"
end
4. Dar Item (Gerar item no inventário)
No script: vRP.GenerateItem(passport, item, amount, true)
Como é no vRPex: vRP.giveInventoryItem(passport, item, amount, true)

📡 Dica de Imagens na NUI
A interface puxa as imagens dos itens diretamente do seu inventário. No arquivo index.html, na linha 364, está o caminho padrão:

JavaScript
function itemIconUrl(itemName){
  return 'nui://vrp/config/inventory/' + itemName + '.png';
}
Se o caminho das imagens do seu servidor for diferente (por exemplo, nui://inventario/nui/images/), basta alterar essa linha no HTML para que as fotos apareçam perfeitamente no tablet.

Suporte
Para problemas técnicos ou dúvidas de adaptação, abra um ticket no Discord da GrK Development.
