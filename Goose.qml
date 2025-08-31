import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Utils

PanelWindow {
  id: root
  color: "transparent"
  anchors {
    left: true
    right: true
    bottom: true
    top: true
}
  mask: Region {}
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  /* ------------------- Parameters ------------------- */
  // use point so we keep fractional position
  property var positionF: Qt.point(width * 0.5, height * 0.75)
  //  0°=right, 90°=down
  property real angleDeg: 40
  property real neckLerp: 0.0

  /* ------------------- Derived vectors  ------------------- */
  readonly property real _rad: angleDeg * Math.PI / 180
  readonly property real _fx:  Math.cos(_rad)
  readonly property real _fy:  Math.sin(_rad)
  readonly property real _lx: -Math.sin(_rad)
  readonly property real _ly:  Math.cos(_rad)
  readonly property real _ux: 0
  readonly property real _uy: -1

  /* ------------------- Integer base ------------------- */
  readonly property int _ix: Math.floor(positionF.x)
  readonly property int _iy: Math.floor(positionF.y)

  /* ------------------- Shadow ------------------- */
  property real shadowRadiusX: 20
  property real shadowRadiusY: 15

  /* ------------------- Feet (float centers) ------------------- */
  property real footRadius: 4
  readonly property var leftFootHome:  Qt.point(_ix, _iy)
  readonly property var rightFootHome: Qt.point(_ix + _lx * 6, _iy + _ly * 6)
  readonly property var lFootPos: leftFootHome
  readonly property var rFootPos: rightFootHome

  /* ------------------- Rig ------------------- */
  readonly property var underbodyCenter: Qt.point(_ix + _ux * 9,  _iy + _uy * 9)
  readonly property var bodyCenter:      Qt.point(_ix + _ux * 14, _iy + _uy * 14)

  readonly property real _neckUp:      20 * (1 - neckLerp) + 10 * neckLerp
  readonly property real _neckForward:  3 * (1 - neckLerp) + 16 * neckLerp

  readonly property var neckBase: Qt.point(
    bodyCenter.x + _fx * 15,
    bodyCenter.y + _fy * 15
  )
  readonly property var neckHeadPoint: Qt.point(
    neckBase.x + _fx * _neckForward + _ux * _neckUp,
    neckBase.y + _fy * _neckForward + _uy * _neckUp
  )
  readonly property var head1End: Qt.point(
    neckHeadPoint.x + _fx * 3 - _ux * 1,
    neckHeadPoint.y + _fy * 3 - _uy * 1
  )
  readonly property var head2End: Qt.point(
    head1End.x + _fx * 5,
    head1End.y + _fy * 5
  )
  readonly property var beakTip: Qt.point(
    head2End.x + _fx * 3,
    head2End.y + _fy * 3
  )

  /* ------------------- Eyes ------------------- */
  readonly property real _bx: 1.3
  readonly property real _by: 0.4
  readonly property real _slx: _lx * _bx    // lateral scaled component-wise
  readonly property real _sly: _ly * _by

  // FLOAT anchor: neckHeadPoint + up*3 + forward*5
  readonly property real _eyeBaseX: neckHeadPoint.x + _ux * 3 + _fx * 5
  readonly property real _eyeBaseY: neckHeadPoint.y + _uy * 3 + _fy * 5

  readonly property real eyeOffset: 5
  readonly property real eyeRadius: 2

  readonly property real leftEyeX:  _eyeBaseX - _slx * eyeOffset   // minus scaled lateral
  readonly property real leftEyeY:  _eyeBaseY - _sly * eyeOffset
  readonly property real rightEyeX: _eyeBaseX + _slx * eyeOffset   // plus  scaled lateral
  readonly property real rightEyeY: _eyeBaseY + _sly * eyeOffset

  /* =================== DRAWING =================== */

  // Shadow (float center is fine)
  Shape {
    anchors.fill: parent
    ShapePath {
      fillColor: Color.shadow; strokeWidth: 0
      PathSvg {
        path: "M " + (_ix - shadowRadiusX) + " " + _iy +
              " a " + shadowRadiusX + " " + shadowRadiusY + " 0 1 0 " + (2*shadowRadiusX) + " 0" +
              " a " + shadowRadiusX + " " + shadowRadiusY + " 0 1 0 " + (-2*shadowRadiusX) + " 0 Z"
      }
    }
  }

  /* Feet (float centers) */
  Shape {
    anchors.fill: parent
    ShapePath {
      fillColor: Color.foot; strokeWidth: 0
      PathSvg {
        path: "M " + (lFootPos.x - footRadius) + " " + lFootPos.y +
              " a " + footRadius + " " + footRadius + " 0 1 0 " + (2*footRadius) + " 0" +
              " a " + footRadius + " " + footRadius + " 0 1 0 " + (-2*footRadius) + " 0 Z"
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      fillColor: Color.foot; strokeWidth: 0
      PathSvg {
        path: "M " + (rFootPos.x - footRadius) + " " + rFootPos.y +
              " a " + footRadius + " " + footRadius + " 0 1 0 " + (2*footRadius) + " 0" +
              " a " + footRadius + " " + footRadius + " 0 1 0 " + (-2*footRadius) + " 0 Z"
      }
    }
  }

  /* ---- Underlayer (LightGray) ---- */
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.under; strokeWidth: 24; fillColor: "transparent"
      capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
      PathSvg { path:
        "M " + Math.floor(bodyCenter.x + _fx*11) + " " + Math.floor(bodyCenter.y + _fy*11) +
        " L " + Math.floor(bodyCenter.x - _fx*11) + " " + Math.floor(bodyCenter.y - _fy*11)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.under; strokeWidth: 15; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(neckBase.x) + " " + Math.floor(neckBase.y) +
        " L " + Math.floor(neckHeadPoint.x) + " " + Math.floor(neckHeadPoint.y)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.under; strokeWidth: 17; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(neckHeadPoint.x) + " " + Math.floor(neckHeadPoint.y) +
        " L " + Math.floor(head1End.x) + " " + Math.floor(head1End.y)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.under; strokeWidth: 12; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(head1End.x) + " " + Math.floor(head1End.y) +
        " L " + Math.floor(head2End.x) + " " + Math.floor(head2End.y)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.under; strokeWidth: 15; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(underbodyCenter.x + _fx*7) + " " + Math.floor(underbodyCenter.y + _fy*7) +
        " L " + Math.floor(underbodyCenter.x - _fx*7) + " " + Math.floor(underbodyCenter.y - _fy*7)
      }
    }
  }

  /* ---- Main (White) ---- */
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.body; strokeWidth: 22; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(bodyCenter.x + _fx*11) + " " + Math.floor(bodyCenter.y + _fy*11) +
        " L " + Math.floor(bodyCenter.x - _fx*11) + " " + Math.floor(bodyCenter.y - _fy*11)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.body; strokeWidth: 13; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(neckBase.x) + " " + Math.floor(neckBase.y) +
        " L " + Math.floor(neckHeadPoint.x) + " " + Math.floor(neckHeadPoint.y)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.body; strokeWidth: 15; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(neckHeadPoint.x) + " " + Math.floor(neckHeadPoint.y) +
        " L " + Math.floor(head1End.x) + " " + Math.floor(head1End.y)
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.body; strokeWidth: 10; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(head1End.x) + " " + Math.floor(head1End.y) +
        " L " + Math.floor(head2End.x) + " " + Math.floor(head2End.y)
      }
    }
  }

  /* ---- Beak ---- */
  Shape {
    anchors.fill: parent
    ShapePath {
      strokeColor: Color.beak; strokeWidth: 9; fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathSvg { path:
        "M " + Math.floor(head2End.x) + " " + Math.floor(head2End.y) +
        " L " + Math.floor(beakTip.x) + " " + Math.floor(beakTip.y)
      }
    }
  }

  /* ---- Eyes (float centers, r=2) ---- */
  Shape {
    anchors.fill: parent
    ShapePath {
      fillColor: Color.eye; strokeWidth: 0
      PathSvg {
        path: "M " + (leftEyeX - eyeRadius) + " " + leftEyeY +
              " a " + eyeRadius + " " + eyeRadius + " 0 1 0 " + (2*eyeRadius) + " 0" +
              " a " + eyeRadius + " " + eyeRadius + " 0 1 0 " + (-2*eyeRadius) + " 0 Z"
      }
    }
  }
  Shape {
    anchors.fill: parent
    ShapePath {
      fillColor: Color.eye; strokeWidth: 0
      PathSvg {
        path: "M " + (rightEyeX - eyeRadius) + " " + rightEyeY +
              " a " + eyeRadius + " " + eyeRadius + " 0 1 0 " + (2*eyeRadius) + " 0" +
              " a " + eyeRadius + " " + eyeRadius + " 0 1 0 " + (-2*eyeRadius) + " 0 Z"
      }
    }
  }
}
