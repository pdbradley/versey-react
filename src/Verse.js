import React from 'react';
import 'bulma/css/bulma.min.css';
import VerseWord from './VerseWord';

const Verse = ({ verse }) => {
  if (!verse) {
    return <div>No Verse</div>;
  }
  return (
    <div className="content">
      {verse.verse_words.map(({ id, word_text, visible }) => (
        <VerseWord key={id} wordText={word_text} visible={visible} />
      ))}
    </div>
  );
};

export default Verse;
