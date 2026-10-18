(function () {
  function initializePuzzleBoard(config) {
    const { rows, columns, frame } = config;
    const trackMoves = config.trackMoves !== false;
    const board = document.querySelector(config.boardSelector ?? '.board');
    const cells = [...board.querySelectorAll('.cell')];
    const handles = [...document.querySelectorAll('.handles button')];
    const feedback = document.querySelector(config.feedbackSelector ?? '#game-feedback');
    const movesLabel = document.querySelector(config.movesSelector ?? '.moves');
    const undoButton = document.querySelector(config.undoSelector ?? '#undo-button');
    const restartButton = document.querySelector(config.restartSelector ?? '#restart-button');

    board.style.setProperty('--rows', rows);
    board.style.setProperty('--columns', columns);
    board.closest('.board-wrap').style.setProperty('--rows', rows);
    board.closest('.board-wrap').style.setProperty('--columns', columns);

    const dateFrame = frame ? board.querySelector('.date-frame') : null;
    function placeDateFrame() {
      if (!dateFrame) return;
      const boardRect = board.getBoundingClientRect();
      const style = getComputedStyle(board);
      const paddingLeft = parseFloat(style.paddingLeft);
      const paddingRight = parseFloat(style.paddingRight);
      const paddingTop = parseFloat(style.paddingTop);
      const paddingBottom = parseFloat(style.paddingBottom);
      const gap = parseFloat(style.columnGap);
      const cellWidth = (boardRect.width - paddingLeft - paddingRight - gap * (columns - 1)) / columns;
      const cellHeight = (boardRect.height - paddingTop - paddingBottom - gap * (rows - 1)) / rows;
      dateFrame.style.left = `${paddingLeft + frame.column * (cellWidth + gap) - gap / 2}px`;
      dateFrame.style.top = `${paddingTop + frame.row * (cellHeight + gap) - gap / 2}px`;
      dateFrame.style.width = `${frame.span * cellWidth + frame.span * gap}px`;
      dateFrame.style.height = `${cellHeight + gap}px`;
      dateFrame.querySelectorAll('.date-separator').forEach((separator, index) => {
        const boundary = index + 1;
        separator.style.left = `${(cellWidth + gap) * boundary}px`;
      });
    }
    if (dateFrame) {
      requestAnimationFrame(placeDateFrame);
      window.addEventListener('resize', placeDateFrame);
    }

    const layout = Array.from({ length: rows }, (_, row) => cells.slice(row * columns, row * columns + columns));
    cells.forEach((cell) => { cell.dataset.value = cell.textContent.trim().replaceAll('−', '-'); });
    const initialValues = cells.map((cell) => cell.dataset.value);
    const initialLayout = layout.map((row) => row.slice());
    const history = [];
    let dragSource;
    let dragTarget;
    let arithmeticSource;
    let moveCount = 0;
    let isResolving = false;

    function updateMoves() {
      if (trackMoves && movesLabel) movesLabel.textContent = `${String(moveCount).padStart(2, '0')} moves`;
      if (undoButton) undoButton.disabled = history.length === 0;
    }

    function captureState() {
      return { values: cells.map((cell) => cell.dataset.value), layout: layout.map((row) => row.slice()), moveCount };
    }

    function saveMove() {
      history.push(captureState());
      moveCount += 1;
      updateMoves();
    }

    function clearArithmetic() {
      arithmeticSource = undefined;
      cells.forEach((cell) => cell.classList.remove('arithmetic-source'));
    }

    function displayValue(value) {
      return String(value).replaceAll('-', '−');
    }

    function sameLine(handle, line) {
      return handle.dataset.kind === line.kind && Number(handle.dataset.index) === line.index;
    }

    function cellsInLine(line) {
      return line.kind === 'row' ? layout[line.index] : layout.map((row) => row[line.index]);
    }

    function clearHighlights() {
      handles.forEach((handle) => handle.classList.remove('drag-source', 'drag-target'));
      cells.forEach((cell) => cell.classList.remove('drag-source', 'drag-target'));
    }

    function clearDrag() {
      clearHighlights();
      board.closest('.board-wrap').classList.remove('is-dragging');
      dragTarget = undefined;
    }

    function paintDrag() {
      clearHighlights();
      if (!dragSource) return;
      board.closest('.board-wrap').classList.add('is-dragging');
      handles.filter((handle) => sameLine(handle, dragSource)).forEach((handle) => handle.classList.add('drag-source'));
      cellsInLine(dragSource).forEach((cell) => cell.classList.add('drag-source'));
      if (!dragTarget) return;
      handles.filter((handle) => sameLine(handle, dragTarget)).forEach((handle) => handle.classList.add('drag-target'));
      cellsInLine(dragTarget).forEach((cell) => cell.classList.add('drag-target'));
    }

    function renderLayout(firstRects) {
      layout.flat().forEach((cell, index) => { cell.style.order = index; });
      if (!firstRects) return;
      requestAnimationFrame(() => cells.forEach((cell) => {
        const first = firstRects.get(cell);
        const last = cell.getBoundingClientRect();
        const x = first.left - last.left;
        const y = first.top - last.top;
        if (!x && !y) return;
        cell.animate([
          { transform: `translate(${x}px, ${y}px) scale(1)`, borderRadius: 'inherit', opacity: 1 },
          { offset: .34, transform: `translate(${x * .7}px, ${y * .7}px) scale(1.07)`, borderRadius: '38% 62% 55% 45% / 48% 43% 57% 52%', opacity: .88 },
          { offset: .74, transform: `translate(${x * .16}px, ${y * .16}px) scale(.98)`, borderRadius: '58% 42% 48% 52% / 43% 58% 42% 57%', opacity: .94 },
          { transform: 'translate(0, 0) scale(1)', borderRadius: 'inherit', opacity: 1 },
        ], { duration: 1180, easing: 'cubic-bezier(.25,.02,.25,1)' });
      }));
    }

    function leaveAfterimage(cell, rect) {
      const ghost = cell.cloneNode(true);
      ghost.className = 'swap-ghost';
      ghost.disabled = true;
      ghost.style.left = `${rect.left}px`;
      ghost.style.top = `${rect.top}px`;
      ghost.style.width = `${rect.width}px`;
      ghost.style.height = `${rect.height}px`;
      document.body.append(ghost);
      ghost.animate([{ opacity: .3, transform: 'scale(1)' }, { opacity: 0, transform: 'scale(1.16)' }], { duration: 1000, easing: 'ease-out' }).finished.then(() => ghost.remove());
    }

    function swapLines(first, second) {
      const firstRects = new Map(cells.map((cell) => [cell, cell.getBoundingClientRect()]));
      saveMove();
      new Set([...cellsInLine(first), ...cellsInLine(second)]).forEach((cell) => leaveAfterimage(cell, firstRects.get(cell)));
      if (first.kind === 'row') {
        [layout[first.index], layout[second.index]] = [layout[second.index], layout[first.index]];
      } else {
        layout.forEach((row) => ([row[first.index], row[second.index]] = [row[second.index], row[first.index]]));
      }
      renderLayout(firstRects);
    }

    function positionOf(cell) {
      for (let row = 0; row < layout.length; row += 1) {
        const column = layout[row].indexOf(cell);
        if (column !== -1) return { row, column };
      }
    }

    function formatOperand(value) {
      return value < 0 ? `(${displayValue(value)})` : displayValue(value);
    }

    function applyArithmetic(targetCell) {
      const sourcePosition = positionOf(arithmeticSource);
      const targetPosition = positionOf(targetCell);
      const sourceValue = Number(arithmeticSource.dataset.value);
      const targetValue = Number(targetCell.dataset.value);
      const add = targetPosition.row > sourcePosition.row || (targetPosition.row === sourcePosition.row && targetPosition.column > sourcePosition.column);
      const result = add ? sourceValue + targetValue : sourceValue - targetValue;
      saveMove();
      targetCell.dataset.value = String(result);
      targetCell.textContent = displayValue(result);
      const equation = document.createElement('span');
      equation.className = 'operation-equation';
      equation.textContent = `${formatOperand(sourceValue)} ${add ? '+' : '−'} ${formatOperand(targetValue)}`;
      targetCell.append(equation);
      isResolving = true;
      board.classList.add('is-resolving');
      targetCell.classList.add('resolving');
      window.setTimeout(() => {
        equation.remove();
        targetCell.classList.remove('resolving');
        board.classList.remove('is-resolving');
        isResolving = false;
      }, 2210);
      clearArithmetic();
      feedback.innerHTML = `<strong>${sourceValue} ${add ? '+' : '−'} ${targetValue} = ${result}.</strong> Choose a source cell.`;
    }

    cells.forEach((cell) => cell.addEventListener('click', () => {
      if (dragSource || isResolving) return;
      if (!arithmeticSource) {
        arithmeticSource = cell;
        cell.classList.add('arithmetic-source');
        feedback.innerHTML = `<strong>${cell.dataset.value} is the source.</strong> Choose a different target cell.`;
        config.onSourceSelected?.(cell);
        return;
      }
      if (arithmeticSource === cell) {
        clearArithmetic();
        feedback.innerHTML = '<strong>Selection cleared.</strong> Choose a source cell.';
        return;
      }
      applyArithmetic(cell);
    }));

    undoButton?.addEventListener('click', () => {
      if (isResolving) return;
      const previous = history.pop();
      if (!previous) return;
      previous.values.forEach((value, index) => { cells[index].dataset.value = value; cells[index].textContent = displayValue(value); });
      layout.splice(0, layout.length, ...previous.layout.map((row) => row.slice()));
      moveCount = previous.moveCount;
      renderLayout();
      clearArithmetic();
      updateMoves();
      feedback.innerHTML = '<strong>Move undone.</strong> Choose a source cell.';
    });

    restartButton?.addEventListener('click', () => {
      if (isResolving) return;
      initialValues.forEach((value, index) => { cells[index].dataset.value = value; cells[index].textContent = displayValue(value); });
      layout.splice(0, layout.length, ...initialLayout.map((row) => row.slice()));
      history.length = 0;
      moveCount = 0;
      renderLayout();
      clearArithmetic();
      updateMoves();
      feedback.innerHTML = '<strong>Game restarted.</strong> Choose a source cell.';
    });

    handles.forEach((handle) => {
      handle.addEventListener('pointerdown', (event) => {
        event.preventDefault();
        if (isResolving) return;
        clearArithmetic();
        dragSource = { kind: handle.dataset.kind, index: Number(handle.dataset.index) };
        handle.setPointerCapture(event.pointerId);
        feedback.innerHTML = `<strong>Dragging ${dragSource.kind} ${dragSource.index + 1}.</strong> Drop it on another ${dragSource.kind}.`;
        paintDrag();
      });
      handle.addEventListener('pointermove', (event) => {
        if (!dragSource) return;
        const candidate = document.elementFromPoint(event.clientX, event.clientY)?.closest('.handles button');
        const valid = candidate && candidate.dataset.kind === dragSource.kind && Number(candidate.dataset.index) !== dragSource.index;
        dragTarget = valid ? { kind: dragSource.kind, index: Number(candidate.dataset.index) } : undefined;
        feedback.innerHTML = dragTarget
          ? `<strong>Swap ${dragSource.kind} ${dragSource.index + 1} with ${dragTarget.index + 1}.</strong> Release to confirm.`
          : `<strong>Dragging ${dragSource.kind} ${dragSource.index + 1}.</strong> Drop it on another ${dragSource.kind}.`;
        paintDrag();
      });
      handle.addEventListener('pointerup', () => {
        if (dragSource && dragTarget) {
          swapLines(dragSource, dragTarget);
          feedback.innerHTML = `<strong>${dragSource.kind[0].toUpperCase() + dragSource.kind.slice(1)}s swapped.</strong> Choose a source cell.`;
        } else {
          feedback.innerHTML = '<strong>Swap cancelled.</strong> Drag a row or column handle onto another one.';
        }
        dragSource = undefined;
        clearDrag();
      });
      handle.addEventListener('pointercancel', () => {
        dragSource = undefined;
        clearDrag();
        feedback.innerHTML = '<strong>Swap cancelled.</strong> Drag a row or column handle onto another one.';
      });
    });
  }

  window.initializePuzzleBoard = initializePuzzleBoard;
}());
