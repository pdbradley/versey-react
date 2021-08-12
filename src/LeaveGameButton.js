import React from 'react';
import { Button } from 'react-bulma-components';
import Cookies from 'universal-cookie';

const LeaveGameButton = () => {
    const cookies = new Cookies();
    let user_uuid = cookies.get('user_uuid');
    let game_session_uuid = window.location.pathname.split('/')[2];

    function handleOnClick(e) {
        e.preventDefault();
        fetch(`${process.env.REACT_APP_HASURA_REST_API}/leave_game_session`, {
            method: 'DELETE',
            body: JSON.stringify({
                game_session_uuid: game_session_uuid,
                user_uuid: user_uuid
            })
        }).then(response =>
            response.json()
        ).then(data => {
            console.log(data);
            window.location = '/games';
        }).catch(error => {
            console.log(error);
            window.location = '/games';
        })
    }

    return (
        <Button color="link" onClick={handleOnClick}>Leave Game</Button>
    );
};
export default LeaveGameButton;