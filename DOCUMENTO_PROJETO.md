# Morcego Lanchonete — Cardápio Digital: Documento Completo

## 1. Visão Geral

Cardápio digital single-page para o **Morcego Lanchonete**, localizado em Santo André – SP. O objetivo é substituir cardápios físicos e facilitar o acesso dos clientes via QR Code ou link direto. O site é 100% estático (sem backend, sem banco de dados), hospedável em qualquer CDN gratuito.

---

## 2. Dados do Estabelecimento

| Campo | Valor |
|-------|-------|
| Nome | Morcego Lanchonete |
| Endereço | R. Siqueira Campos, 1039 — Centro, Santo André – SP, 09020-240 |
| Funcionamento | QUI 18h–01h · SEX 19h–01h · SAB 18h–01h · DOM 17h–22h |
| WhatsApp | Não cadastrado (pendente) |
| GitHub | github.com/gzuisx/morcego-cardapio |

---

## 3. Stack Técnica

- **Frontend**: HTML5 + CSS3 + JavaScript puro (vanilla), sem frameworks
- **Fontes**: Google Fonts (Playfair Display, DM Sans, DM Mono)
- **Imagens**: CDN externo (`zig-public.zig.fun` e `zig-public-files.zig.fun`)
- **Backend**: Nenhum — site 100% estático
- **Versionamento**: Git + GitHub (`gzuisx/morcego-cardapio`)
- **Deploy**: A definir (sugestão: Vercel, Netlify ou GitHub Pages — gratuito)

---

## 4. Funcionalidades Implementadas

| Funcionalidade | Status |
|---------------|--------|
| Hero de entrada com animação | ✅ |
| Título "MORCEGO" (fonte a definir) | ✅ parcial (fonte pendente) |
| Morcegos flutuando no fundo (canvas) | ✅ |
| Morcegos flutuando subindo (partículas) | ✅ |
| Navegação por categorias (mobile: bottom nav / desktop: sidebar) | ✅ |
| Cards de itens com imagem, nome, preço, descrição | ✅ |
| Modal de detalhe do item com extras/variações selecionáveis | ✅ |
| Busca por nome de item | ✅ |
| Status Aberto/Fechado dinâmico por dia e horário | ✅ |
| Endereço e horários no header | ✅ |
| Botão WhatsApp por item | ⏳ (aguardando número) |
| QR Code | ⏳ (aguardando URL de deploy) |
| Modo PWA / offline | ❌ não implementado |

---

## 5. Categorias do Cardápio

1. 🛍️ Lojinha (3 itens — camisetas, serigrafia)
2. ⭐ Destaques (2 itens)
3. 🍺 Cervejas (5 itens)
4. 🍹 Drinks Autorais (10 itens)
5. 🥂 Drinks (25+ itens)
6. 🍔 Rango (8 itens)
7. 🌿 Vegano (1 item)
8. 🍟 Porções (4 itens)
9. 🍮 Sobremesa (1 item)
10. 🥤 Sem Álcool (11 itens)
11. 🥃 Destilados (12 itens)
12. 🍷 Vinhos (10 itens)

**Total estimado:** ~92 itens

---

## 6. Arquitetura do Código

O site é um único arquivo `index.html` com CSS e JavaScript inline. Estrutura:

```
index.html
├── <head>         — meta, fontes, estilos CSS completos
├── <body>
│   ├── #batCanvas         — canvas com morcegos de fundo (horizontal drift)
│   ├── #floatParticles    — morcegos subindo (CSS animation)
│   ├── #hero              — tela de entrada (dismissível)
│   ├── #app
│   │   ├── .header        — barra superior com status, busca, info
│   │   ├── .bottom-nav    — navegação mobile
│   │   └── .layout
│   │       ├── .sidebar   — navegação desktop
│   │       └── .main      — conteúdo gerado via JS
│   └── #modalOverlay      — modal de detalhe dos itens
└── <script>
    ├── WPP_NUMBER         — número do WhatsApp (null por ora)
    ├── categories[]       — todos os dados do cardápio
    ├── Canvas bats        — animação de morcegos voando
    ├── Floating particles — morcegos subindo
    ├── Hero dismiss       — lógica de entrada
    ├── Search             — filtro de busca
    ├── buildNav()         — gera navegação dinâmica
    ├── buildContent()     — gera cards e seções
    ├── openModal()        — abre modal de item
    ├── updateNav()        — destaca seção ativa no scroll
    └── updateStatus()     — status aberto/fechado dinâmico
```

---

## 7. QR Code — Análise

### Como funciona
Um QR Code é gerado uma vez e aponta para a URL do site. Quando o cliente escaneia, abre o cardápio no browser do celular.

### Requisitos
- **URL pública e estável** — o site precisa estar hospedado antes de gerar o QR
- Sugestão de URL: `https://morcego-cardapio.vercel.app` ou domínio próprio

### Como gerar (gratuito)
- **qr-code-generator.com** — exporta PNG/SVG em alta resolução
- **qrcode.react** — biblioteca se quiser embutir no próprio site
- Tamanho mínimo para impressão: 3cm × 3cm a 300dpi

### Problema potencial
Se a URL mudar, o QR impresso fica inválido. Usar domínio próprio ou serviço de redirecionamento (ex: `bit.ly`) garante que dá para trocar o destino sem reimprimir.

---

## 8. Brechas e Erros Potenciais

### 8.1 Imagens
- **Risco:** Imagens hospedadas em CDN externo (`zig-public.zig.fun`). Se esse serviço cair ou bloquear o domínio do cardápio (CORS), todas as imagens somem.
- **Mitigação:** Baixar as imagens e hospedar junto com o site, ou usar CDN confiável (Cloudinary, imgix).

### 8.2 Fontes do Google
- **Risco:** Se o cliente não tiver internet, fontes não carregam — fallback para sans-serif genérico, layout pode quebrar.
- **Mitigação:** Hospedar as fontes localmente (subconjunto WOFF2).

### 8.3 Status aberto/fechado
- **Risco:** O horário usa o relógio do celular do cliente. Se o cliente estiver em fuso diferente (ex: turista), status fica errado.
- **Mitigação:** Forçar timezone de São Paulo no JS: `new Date().toLocaleString('pt-BR', {timeZone: 'America/Sao_Paulo'})`.

### 8.4 Sem HTTPS
- **Risco:** Servir via `file://` ou HTTP sem TLS faz o browser bloquear recursos mistos e impede PWA/câmera para QR Code gerado no site.
- **Mitigação:** Hospedar com HTTPS (Vercel/Netlify já entregam isso gratuitamente).

### 8.5 Dados do cardápio hardcoded
- **Risco:** Para atualizar preço, nome ou adicionar item, alguém precisa editar o HTML e fazer deploy. Sem painel.
- **Mitigação:** Migrar `categories[]` para um JSON externo (ex: GitHub Gist ou Supabase) — dono edita sem tocar no código.

### 8.6 Sem fallback offline
- **Risco:** Se o cliente tentar ver o cardápio sem internet no bar (Wi-Fi ruim), site não carrega.
- **Mitigação:** Transformar em PWA com Service Worker — cache do HTML e imagens no primeiro acesso.

### 8.7 WhatsApp sem número
- **Risco:** Botão "Pedir" está oculto, mas se alguém inspecionar o HTML, vê `WPP_NUMBER = null`. Não é segurança crítica, mas indica que o cardápio está incompleto.
- **Mitigação:** Adicionar número real quando disponível.

### 8.8 XSS / Injeção
- **Risco:** A busca usa `.textContent` para renderizar resultados (seguro). O conteúdo do cardápio é hardcoded. Não há input que vá para URL ou `innerHTML` sem sanitização — risco baixo.
- **Status:** Seguro no estado atual.

### 8.9 Performance em mobile com muitos itens
- **Risco:** ~92 itens renderizados de uma vez. Em celulares antigos pode travar o scroll.
- **Mitigação:** Implementar lazy loading dos cards (IntersectionObserver).

---

## 9. Segurança Geral

| Item | Avaliação |
|------|-----------|
| XSS | ✅ Sem risco (sem innerHTML com input do usuário) |
| SQL Injection | ✅ N/A (sem banco de dados) |
| CSRF | ✅ N/A (sem formulários de autenticação) |
| HTTPS | ⚠️ Depende do deploy |
| Dados sensíveis expostos | ⚠️ Token GitHub no remote URL (local) — não exposto no site |
| Dependências externas | ⚠️ CDN de imagens externo (risco de queda) |

---

## 10. Próximos Passos Recomendados

1. **Escolher fonte horror** e aplicar no título "MORCEGO"
2. **Deploy** — Vercel (recomendado, gratuito, HTTPS automático)
3. **Gerar QR Code** após URL de deploy confirmada
4. **Corrigir timezone** no status aberto/fechado (America/Sao_Paulo)
5. **Adicionar número WhatsApp** quando disponível
6. **Migrar imagens** para CDN próprio ou confiável
7. **Painel simples** para dono atualizar cardápio sem código (opcional)

---

*Documento gerado em: 2026-06-01*
*Projeto: github.com/gzuisx/morcego-cardapio*
