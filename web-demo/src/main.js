const STORAGE_KEY = 'flashfill_shortcuts_v1'

const DEFAULTS = [
  { id: crypto.randomUUID(), label: '姓', value: '张', color: '#4A90E2', shape: 'roundedRect' },
  { id: crypto.randomUUID(), label: '名', value: '三', color: '#4A90E2', shape: 'roundedRect' },
  { id: crypto.randomUUID(), label: '邮箱', value: 'zhangsan@example.com', color: '#7B68C7', shape: 'circle' },
  { id: crypto.randomUUID(), label: '电话', value: '13800138000', color: '#F0C040', shape: 'circle' },
  { id: crypto.randomUUID(), label: '后四位', value: '1234', color: '#E85D5D', shape: 'circle' }
]

const field = document.getElementById('field')
const mirror = document.getElementById('mirror')
const keyboard = document.getElementById('keyboard')
const list = document.getElementById('list')
const addBtn = document.getElementById('addBtn')
const editor = document.getElementById('editor')
const editorForm = document.getElementById('editorForm')
const editorTitle = document.getElementById('editorTitle')
const cancelEdit = document.getElementById('cancelEdit')

let items = load()
let editingId = null

function load() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return structuredClone(DEFAULTS)
    const parsed = JSON.parse(raw)
    return Array.isArray(parsed) && parsed.length ? parsed : structuredClone(DEFAULTS)
  } catch {
    return structuredClone(DEFAULTS)
  }
}

function save() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items))
}

function syncMirror() {
  mirror.textContent = field.value || '（输入会显示在这里）'
}

function insertText(text) {
  const start = field.selectionStart ?? field.value.length
  const end = field.selectionEnd ?? field.value.length
  field.value = field.value.slice(0, start) + text + field.value.slice(end)
  const pos = start + text.length
  field.setSelectionRange(pos, pos)
  field.focus()
  syncMirror()
}

function deleteBackward() {
  const start = field.selectionStart ?? 0
  const end = field.selectionEnd ?? 0
  if (start !== end) {
    field.value = field.value.slice(0, start) + field.value.slice(end)
    field.setSelectionRange(start, start)
  } else if (start > 0) {
    field.value = field.value.slice(0, start - 1) + field.value.slice(start)
    field.setSelectionRange(start - 1, start - 1)
  }
  field.focus()
  syncMirror()
}

function clearAll() {
  field.value = ''
  field.focus()
  syncMirror()
}

function renderKeyboard() {
  const rects = items.filter((i) => i.shape === 'roundedRect')
  const circles = items.filter((i) => i.shape === 'circle')
  const left = rects.length ? rects.slice(0, 3) : items.slice(0, 2)
  const right = rects.length ? circles.concat(rects.slice(3)) : items.slice(2)

  keyboard.innerHTML = `
    <div class="shortcuts">
      <div class="left-col" id="leftCol"></div>
      <div class="circles" id="circles"></div>
    </div>
    <div class="controls">
      <button type="button" class="ctrl space" data-act="space">空格</button>
      <button type="button" class="ctrl clear" data-act="clear" aria-label="清空">🗑</button>
      <button type="button" class="ctrl back" data-act="back" aria-label="退格">⌫</button>
      <button type="button" class="ctrl enter" data-act="enter">换行</button>
    </div>
  `

  const leftCol = keyboard.querySelector('#leftCol')
  const circlesEl = keyboard.querySelector('#circles')

  if (!items.length) {
    circlesEl.innerHTML = '<div class="empty">请先添加快捷内容</div>'
  } else {
    left.forEach((item) => leftCol.appendChild(makeKey(item, 'rect')))
    right.forEach((item) => circlesEl.appendChild(makeKey(item, 'circle')))
  }

  keyboard.querySelectorAll('[data-act]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const act = btn.getAttribute('data-act')
      if (act === 'space') insertText(' ')
      if (act === 'clear') clearAll()
      if (act === 'back') deleteBackward()
      if (act === 'enter') insertText('\n')
    })
  })
}

function makeKey(item, className) {
  const btn = document.createElement('button')
  btn.type = 'button'
  btn.className = `key ${className}`
  btn.style.background = item.color
  btn.textContent = item.label
  btn.addEventListener('click', () => insertText(item.value || item.label))
  return btn
}

function renderList() {
  list.innerHTML = ''
  items.forEach((item) => {
    const li = document.createElement('li')
    li.innerHTML = `
      <div class="swatch ${item.shape}" style="background:${item.color}">${item.label.slice(0, 2)}</div>
      <div class="meta"><strong>${escapeHtml(item.label)}</strong><span>${escapeHtml(item.value)}</span></div>
      <div>
        <button type="button" data-edit="${item.id}">编辑</button>
        <button type="button" data-del="${item.id}">删除</button>
      </div>
    `
    list.appendChild(li)
  })

  list.querySelectorAll('[data-edit]').forEach((btn) => {
    btn.addEventListener('click', () => openEditor(btn.getAttribute('data-edit')))
  })
  list.querySelectorAll('[data-del]').forEach((btn) => {
    btn.addEventListener('click', () => {
      items = items.filter((i) => i.id !== btn.getAttribute('data-del'))
      save()
      renderAll()
    })
  })
}

function escapeHtml(s) {
  return String(s)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
}

function openEditor(id = null) {
  editingId = id
  editorTitle.textContent = id ? '编辑内容' : '添加内容'
  const item = items.find((i) => i.id === id)
  editorForm.label.value = item?.label ?? ''
  editorForm.value.value = item?.value ?? ''
  editorForm.shape.value = item?.shape ?? 'circle'
  const color = item?.color ?? '#3CB371'
  const radio = editorForm.querySelector(`input[name="color"][value="${color}"]`)
  if (radio) radio.checked = true
  else editorForm.querySelector('input[name="color"]').checked = true
  editor.showModal()
}

function renderAll() {
  renderKeyboard()
  renderList()
}

addBtn.addEventListener('click', () => openEditor(null))
cancelEdit.addEventListener('click', () => editor.close())
field.addEventListener('input', syncMirror)

editorForm.addEventListener('submit', (e) => {
  e.preventDefault()
  const data = new FormData(editorForm)
  const next = {
    id: editingId ?? crypto.randomUUID(),
    label: String(data.get('label') || '').trim(),
    value: String(data.get('value') || '').trim(),
    shape: String(data.get('shape') || 'circle'),
    color: String(data.get('color') || '#4A90E2')
  }
  if (!next.label || !next.value) return
  if (editingId) {
    items = items.map((i) => (i.id === editingId ? next : i))
  } else {
    items.push(next)
  }
  save()
  editor.close()
  renderAll()
})

renderAll()
syncMirror()
field.focus()
