<?php
/**
 * DokuWiki Plugin authdiscoursedb (Auth Component)
 *
 * Using Discourse as a SSO provider
 * https://meta.discourse.org/t/using-discourse-as-a-sso-provider/32974
 *
 * @license GPL 2 http://www.gnu.org/licenses/gpl-2.0.html
 * @author  La Chouette Coop  <info@lachouettecoop.fr>
 */

// must be run within Dokuwiki
if(!defined('DOKU_INC')) die();

class auth_plugin_authdiscoursedb extends DokuWiki_Auth_Plugin {

    private $db = false;

    /**
     * Constructor.
     */
    public function __construct() {
        parent::__construct(); // for compatibility

        $this->cando['addUser']     = false; // can Users be created?
        $this->cando['delUser']     = false; // can Users be deleted?
        $this->cando['modLogin']    = false; // can login names be changed?
        $this->cando['modPass']     = false; // can passwords be changed?
        $this->cando['modName']     = false; // can real names be changed?
        $this->cando['modMail']     = false; // can emails be changed?
        $this->cando['modGroups']   = false; // can groups be changed?
        $this->cando['getUsers']    = false; // can a (filtered) list of users be retrieved?
        $this->cando['getUserCount']= false; // can the number of users be retrieved?
        $this->cando['getGroups']   = true; // can a list of available groups be retrieved?
        $this->cando['external']    = true; // does the module do external auth checking?
        $this->cando['logout']      = true; // can the user logout again? (eg. not possible with HTTP auth)


        $dbhost = parse_url(getenv('POSTGRES_PORT'), PHP_URL_HOST);
        $dbport = parse_url(getenv('POSTGRES_PORT'), PHP_URL_PORT);
        $dbuser = getenv('POSTGRES_ENV_POSTGRES_USER');
        $dbpass = getenv('POSTGRES_ENV_POSTGRES_PASSWORD');
        $dbstring = 'host=' . $dbhost . ' port=' . $dbport . ' dbname=discourse user=' . $dbuser . ' password=' . $dbpass;

        $this->db = pg_connect($dbstring);

        if ($this->db === false) {
            $this->success = false;
            msg('Plugin authdiscoursedb: discourse database connection failed', -1);
        } else {
            $this->success = true;
        }
    }


    /**
     * Log off the current user [ OPTIONAL ]
     */
    //public function logOff() {
    //}

    /**
     * Do all authentication [ OPTIONAL ]
     *
     * @param   string  $user    Username
     * @param   string  $pass    Cleartext Password
     * @param   bool    $sticky  Cookie should not expire
     * @return  bool             true on successful auth
     */
    public function trustExternal($user, $pass, $sticky = false) {

        global $USERINFO;
		global $conf;
 
		$sticky ? $sticky = true : $sticky = false; //sanity check
 
		if (!empty($_SESSION[DOKU_COOKIE]['auth']['info'])) {
			$USERINFO['name'] = $_SESSION[DOKU_COOKIE]['auth']['info']['user'];
			$USERINFO['mail'] = $_SESSION[DOKU_COOKIE]['auth']['info']['mail'];
			$USERINFO['grps'] = $_SESSION[DOKU_COOKIE]['auth']['info']['grps'];
			$_SERVER['REMOTE_USER'] = $_SESSION[DOKU_COOKIE]['auth']['user'];
			return true;
		}
 
		if (!empty($user)) {
			// do the checking here

            $result = pg_query_params($this->db, 'SELECT id,username,password_hash,salt,name,email,admin FROM users WHERE active=true AND email=$1', array($user));
            $row = pg_fetch_assoc ($result, 0);

            if ($row === false) {
				msg('Incorrect username or password.');
                return false;
            }

            if ($row['password_hash'] != hash_pbkdf2('sha256', $pass, $row['salt'] , 64000)) {
				msg('Incorrect username or password.');
				return false;
			}

            if (in_array($user, explode(" ",$this->getConf('admin_users')))) {
                $row['admin'] = true;
            }

            $groups = $row['admin'] == true ? array('admin','user'): array( 'user');
 
			// set the globals if authed
			$USERINFO['name'] = $row['username'];
			$USERINFO['mail'] = $row['email'];
			$USERINFO['grps'] = $groups;

			$_SERVER['REMOTE_USER'] = $row['name'];
			$_SESSION[DOKU_COOKIE]['auth']['user'] = $row['username'];
			$_SESSION[DOKU_COOKIE]['auth']['mail'] = $row['email'];
			$_SESSION[DOKU_COOKIE]['auth']['pass'] = $pass;
			$_SESSION[DOKU_COOKIE]['auth']['info'] = $USERINFO;
			return true;
		} else {
			return false;
		}
    }

    /**
     * Check user+password
     *
     * May be ommited if trustExternal is used.
     *
     * @param   string $user the user name
     * @param   string $pass the clear text password
     * @return  bool
     */
    public function checkPass($user, $pass) {
        // FIXME implement password check
        return false; // return true if okay
    }

    /**
     * Return user info
     *
     * Returns info about the given user needs to contain
     * at least these fields:
     *
     * name string  full name of the user
     * mail string  email addres of the user
     * grps array   list of groups the user is in
     *
     * @param   string $user the user name
     * @return  array containing user data or false
     * @param   bool $requireGroups whether or not the returned data must include groups
     */
    public function getUserData($user, $requireGroups=true) {
        // FIXME implement
        return false;
    }

    /**
     * Create a new User [implement only where required/possible]
     *
     * Returns false if the user already exists, null when an error
     * occurred and true if everything went well.
     *
     * The new user HAS TO be added to the default group by this
     * function!
     *
     * Set addUser capability when implemented
     *
     * @param  string     $user
     * @param  string     $pass
     * @param  string     $name
     * @param  string     $mail
     * @param  null|array $grps
     * @return bool|null
     */
    //public function createUser($user, $pass, $name, $mail, $grps = null) {
        // FIXME implement
    //    return null;
    //}

    /**
     * Modify user data [implement only where required/possible]
     *
     * Set the mod* capabilities according to the implemented features
     *
     * @param   string $user    nick of the user to be changed
     * @param   array  $changes array of field/value pairs to be changed (password will be clear text)
     * @return  bool
     */
    //public function modifyUser($user, $changes) {
        // FIXME implement
    //    return false;
    //}

    /**
     * Delete one or more users [implement only where required/possible]
     *
     * Set delUser capability when implemented
     *
     * @param   array  $users
     * @return  int    number of users deleted
     */
    //public function deleteUsers($users) {
        // FIXME implement
    //    return false;
    //}

    /**
     * Bulk retrieval of user data [implement only where required/possible]
     *
     * Set getUsers capability when implemented
     *
     * @param   int   $start     index of first user to be returned
     * @param   int   $limit     max number of users to be returned, 0 for unlimited
     * @param   array $filter    array of field/pattern pairs, null for no filter
     * @return  array list of userinfo (refer getUserData for internal userinfo details)
     */
    //public function retrieveUsers($start = 0, $limit = 0, $filter = null) {
        // FIXME implement
    //    return array();
    //}

    /**
     * Return a count of the number of user which meet $filter criteria
     * [should be implemented whenever retrieveUsers is implemented]
     *
     * Set getUserCount capability when implemented
     *
     * @param  array $filter array of field/pattern pairs, empty array for no filter
     * @return int
     */
    //public function getUserCount($filter = array()) {
    //    $result = pg_query($this->db, 'SELECT count(id) FROM users WHERE active=true');
    //    return pg_fetch_result($result, 0, 0);
    //}

    /**
     * Define a group [implement only where required/possible]
     *
     * Set addGroup capability when implemented
     *
     * @param   string $group
     * @return  bool
     */
    //public function addGroup($group) {
        // FIXME implement
    //    return false;
    //}

    /**
     * Retrieve groups [implement only where required/possible]
     *
     * Set getGroups capability when implemented
     *
     * @param   int $start
     * @param   int $limit
     * @return  array
     */
    public function retrieveGroups($start = 0, $limit = 0) {
        $groups = array('admin', 'user');

        //$result = pg_query($this->db, 'SELECT name FROM groups WHERE visible=true');
        //while($row = pg_fetch_array($result)) {
        //    $groups[] = $row[0];
        //}

        if ($limit != 0) {
            return array_slice($groups, $start, $limit);
        } else {
            return array_slice($groups, $start);
        }
    }

    /**
     * Return case sensitivity of the backend
     *
     * When your backend is caseinsensitive (eg. you can login with USER and
     * user) then you need to overwrite this method and return false
     *
     * @return bool
     */
    public function isCaseSensitive() {
        return true;
    }

    /**
     * Sanitize a given username
     *
     * This function is applied to any user name that is given to
     * the backend and should also be applied to any user name within
     * the backend before returning it somewhere.
     *
     * This should be used to enforce username restrictions.
     *
     * @param string $user username
     * @return string the cleaned username
     */
    public function cleanUser($user) {
        return $user;
    }

    /**
     * Sanitize a given groupname
     *
     * This function is applied to any groupname that is given to
     * the backend and should also be applied to any groupname within
     * the backend before returning it somewhere.
     *
     * This should be used to enforce groupname restrictions.
     *
     * Groupnames are to be passed without a leading '@' here.
     *
     * @param  string $group groupname
     * @return string the cleaned groupname
     */
    public function cleanGroup($group) {
        return $group;
    }

    /**
     * Check Session Cache validity [implement only where required/possible]
     *
     * DokuWiki caches user info in the user's session for the timespan defined
     * in $conf['auth_security_timeout'].
     *
     * This makes sure slow authentication backends do not slow down DokuWiki.
     * This also means that changes to the user database will not be reflected
     * on currently logged in users.
     *
     * To accommodate for this, the user manager plugin will touch a reference
     * file whenever a change is submitted. This function compares the filetime
     * of this reference file with the time stored in the session.
     *
     * This reference file mechanism does not reflect changes done directly in
     * the backend's database through other means than the user manager plugin.
     *
     * Fast backends might want to return always false, to force rechecks on
     * each page load. Others might want to use their own checking here. If
     * unsure, do not override.
     *
     * @param  string $user - The username
     * @return bool
     */
    //public function useSessionCache($user) {
      // FIXME implement
    //}
}

// vim:ts=4:sw=4:et:
