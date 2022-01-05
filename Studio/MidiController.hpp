/**
 * @ Author: Cédric Lucchese
 * @ Description: Midi Controller Header
 */

#include <QTimer>
#include <QObject>
#include <QDebug>

#include "C:/vcpkg/packages/rtmidi_x64-windows-static/include/RtMidi.h"

/** @brief Midi Controller class */
class MidiController : public QObject
{
    Q_OBJECT
    
public:
    /** @brief Construct a new Midi Controller object */
    MidiController(void);

public slots:
    /** @brief Infinite loop which get midi events and emit output signal */
    void input() const noexcept;

signals:
    /** @brief Output signal */
    void output(bool noteOn, int noteNumber, int velocity) const;

private:
    /** @brief return if the note is on */
    bool noteOn(int message) const noexcept;

    QTimer _timer = QTimer(this);
    RtMidiIn *_midiIn = new RtMidiIn();
    unsigned int _portCount = 0;
};



