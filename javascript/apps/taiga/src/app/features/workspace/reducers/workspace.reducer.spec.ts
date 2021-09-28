/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

import { initialState, workspaceFeature } from './workspace.reducer';

describe('Workspace Reducer', () => {
  it('unknown action', () => {
    const action = {} as any;

    const result = workspaceFeature.reducer(initialState, action);

    expect(result).toBe(initialState);
  });
});
