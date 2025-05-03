/*
 * @file      Field.swift
 *
 * @brief     Field class for each parameter
 *
 * @author    Decawave Applications
 *
 * @attention Copyright (c) 2021 - 2022, Qorvo US, Inc.
 * All rights reserved
 * Redistribution and use in source and binary forms, with or without modification,
 *  are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 *  list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 * 3. You may only use this software, with or without any modification, with an
 *  integrated circuit developed by Qorvo US, Inc. or any of its affiliates
 *  (collectively, "Qorvo"), or any module that contains such integrated circuit.
 * 4. You may not reverse engineer, disassemble, decompile, decode, adapt, or
 *  otherwise attempt to derive or gain access to the source code to any software
 *  distributed under this license in binary or object code form, in whole or in
 *  part.
 * 5. You may not use any Qorvo name, trademarks, service marks, trade dress,
 *  logos, trade names, or other symbols or insignia identifying the source of
 *  Qorvo's products or services, or the names of any of Qorvo's developers to
 *  endorse or promote products derived from this software without specific prior
 *  written permission from Qorvo US, Inc. You must not call products derived from
 *  this software "Qorvo", you must not have "Qorvo" appear in their name, without
 *  the prior permission from Qorvo US, Inc.
 * 6. Qorvo may publish revised or new version of this license from time to time.
 *  No one other than Qorvo US, Inc. has the right to modify the terms applicable
 *  to the software provided under this license.
 * THIS SOFTWARE IS PROVIDED BY QORVO US, INC. "AS IS" AND ANY EXPRESS OR IMPLIED
 *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. NEITHER
 *  QORVO, NOR ANY PERSON ASSOCIATED WITH QORVO MAKES ANY WARRANTY OR
 *  REPRESENTATION WITH RESPECT TO THE COMPLETENESS, SECURITY, RELIABILITY, OR
 *  ACCURACY OF THE SOFTWARE, THAT IT IS ERROR FREE OR THAT ANY DEFECTS WILL BE
 *  CORRECTED, OR THAT THE SOFTWARE WILL OTHERWISE MEET YOUR NEEDS OR EXPECTATIONS.
 * IN NO EVENT SHALL QORVO OR ANYBODY ASSOCIATED WITH QORVO BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 *
 */

import UIKit

class Field: UIView {
    // MARK: – Subviews
    let fieldIcon: UIImageView
    let valueLabel: UILabel
    let titleLabel: UILabel
    // Stack View to organise
    let verticalStackView: UIStackView

    init(image: UIImage?, fieldTitle: String) {
        // 1) Icon image
        fieldIcon = UIImageView(image: image)
        fieldIcon.contentMode = .scaleAspectFit
        fieldIcon.translatesAutoresizingMaskIntoConstraints = false

        // 2) Value label (read‑only)
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .dinNextMedium_l
        valueLabel.textAlignment = .center
        valueLabel.textColor = .black
        valueLabel.text = "-"

        // 3) Title label (read‑only)
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .dinNextRegular_s
        titleLabel.textAlignment = .center
        titleLabel.textColor = .qorvoGray33
        titleLabel.text = fieldTitle

        // 4) Stack view
        verticalStackView = UIStackView(arrangedSubviews: [fieldIcon, valueLabel, titleLabel])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
        verticalStackView.spacing = 0

        super.init(frame: .zero)

        // Add and constrain
        addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            // Icon size and centering
            fieldIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            fieldIcon.heightAnchor.constraint(equalToConstant: FIELD_ICON_SIDE_CONSTRAINT),
            fieldIcon.widthAnchor.constraint(equalToConstant: FIELD_ICON_SIDE_CONSTRAINT),

            // Value label height and centering
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.heightAnchor.constraint(equalToConstant: VALUE_TEXT_HEIGHT_CONSTRAINT),

            // Title label height and centering
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: TITLE_TEXT_HEIGHT_CONSTRAINT),

            // Stack view edges
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Public API

    /// Update the displayed value.
    func setValue(_ newValue: String) {
        valueLabel.text = newValue
    }

    /// Dim or restore the value label.
    func setDisable(_ disable: Bool) {
        valueLabel.textColor = disable ? .lightGray : .black
    }
}


// MARK: – Convenience Accessor
extension Field {
    /// Returns the current text in this field’s value area.
    var currentValue: String {
        // If you still use UITextField internally, swap valueLabel -> valueText
        return self.valueLabel.text ?? ""
    }
}
