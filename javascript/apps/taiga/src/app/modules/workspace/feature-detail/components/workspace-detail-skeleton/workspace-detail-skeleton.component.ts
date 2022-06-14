/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

import {
  ChangeDetectionStrategy,
  Component,
  HostBinding,
  Input,
} from '@angular/core';

@Component({
  selector: 'tg-workspace-detail-skeleton',
  templateUrl: './workspace-detail-skeleton.component.html',
  styleUrls: ['./workspace-detail-skeleton.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class WorkspaceDetailSkeletonComponent {
  @HostBinding('class.static') @Input() public static = false;
}
