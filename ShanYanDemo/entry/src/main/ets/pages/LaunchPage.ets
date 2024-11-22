// -*- coding: utf-8 -*-
// Project    : ShanYanDemo
// File       : MenuPage.ets
// Time       ：2024/10/28
// Author     ：ya dong
// Copyright © 2024 CL. All rights reserved.

import { router } from '@kit.ArkUI'

@Entry
@Component
struct LaunchPage {
  @State duration: number = 1
  private intervalId: number = -1

  goToHomePage() {
    clearInterval(this.intervalId)
    router.replaceUrl({ url: 'pages/MenuPage' })
  }

  aboutToAppear() {
    this.intervalId = setInterval(() => {
      if (this.duration > 1) {
        this.duration -= 1
      } else {
        this.goToHomePage()
      }
    }, 1000)
  }

  build() {
    Column() {
      Row() {
        Text() {
          Span("跳过")
          Span(": " + this.duration)
        }
        .fontSize(12)
        .fontColor(Color.White)
        .borderRadius(16)
        .letterSpacing(1)
        .height(36)
        .backgroundColor('rgba(0,0,0,0.20)')
        .border({ color: Color.White, width: 1 })
        .margin({ top: 36 })
        .padding(8)
        .onClick(() => {
          this.goToHomePage()
        })
      }
      .width('90%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
    .backgroundImagePosition({ x: 0, y: 0 })
    .backgroundImage($r('app.media.launch'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}